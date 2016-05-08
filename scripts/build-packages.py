#!/usr/bin/env python


import os
import glob
import subprocess as sp
import argparse
import sys
from collections import defaultdict, Iterable
from itertools import product, chain

import networkx as nx
import nose
from conda_build.metadata import MetaData
import yaml


def flatten_dict(dict):
    for key, values in dict.items():
        if isinstance(values, str) or not isinstance(values, Iterable):
            values = [values]
        yield [(key, value) for value in values]


class EnvMatrix:
    def __init__(self, path):
        with open(path) as f:
            self.env = yaml.load(f)

    def __iter__(self):
        for env in product(*flatten_dict(self.env)):
            e = dict(os.environ)
            e.update(env)
            yield e


def get_metadata(recipes):
    for recipe in recipes:
        yield MetaData(recipe)


def get_deps(metadata, build=True):
    for dep in metadata.get_value("requirements/{}".format("build" if build else "run"), []):
        yield dep.split()[0]


def get_dag(recipes):
    metadata = list(get_metadata(recipes))

    name2recipe = defaultdict(list)
    for meta, recipe in zip(metadata, recipes):
        name2recipe[meta.get_value("package/name")].append(recipe)

    def get_inner_deps(dependencies):
        for dep in dependencies:
            name = dep.split()[0]
            if name in name2recipe:
                yield name

    dag = nx.DiGraph()
    dag.add_nodes_from(meta.get_value("package/name") for meta in metadata)
    for meta in metadata:
        name = meta.get_value("package/name")
        dag.add_edges_from((dep, name) for dep in set(get_inner_deps(chain(get_deps(meta), get_deps(meta, build=False)))))

    #nx.relabel_nodes(dag, name2recipe, copy=False)
    return dag, name2recipe


def conda_index():
    index_dirs = [
        "/anaconda/conda-bld/linux-64",
        "/anaconda/conda-bld/osx-64",
    ]
    sp.run(["conda", "index"] + index_dirs, check=True, stdout=sp.PIPE)


def build_recipe(recipe, env_matrix, testonly=False):
    def build(env):
        try:
            out = None if args.verbose else sp.PIPE
            build_args = []
            if testonly:
                build_args.append("--test")
            else:
                build_args += ["--no-anaconda-upload", "--skip-existing"]
            sp.run(["conda", "build", "--quiet", recipe] + build_args,
                   stderr=out, stdout=out, check=True, universal_newlines=True,
                   env=env)
            return True
        except sp.CalledProcessError as e:
            if e.stdout is not None:
                print(e.stdout)
                print(e.stderr)
            return False

    conda_index()
    # use list to enforce all builds
    success = all(list(map(build, env_matrix)))

    if not success:
        # fail if all builds result in an error
        assert False, "At least one build of recipe {} failed.".format(recipe)


def filter_recipes(recipes, env_matrix):
    def msgs(env):
        p = sp.run(
            ["conda", "build", "--skip-existing", "--output"] + recipes,
            check=True, stdout=sp.PIPE, stderr=sp.PIPE, universal_newlines=True,
            env=env
        )
        return [msg for msg in p.stdout.split("\n") if "Ignoring non-recipe" not in msg][1:-1]
    skip = lambda msg: "already built, skipping" in msg or "defines build/skip" in msg

    try:
        for item in zip(recipes, *map(msgs, env_matrix)):
            recipe = item[0]
            msg = item[1:]

            if not all(map(skip, msg)):
                yield recipe
    except sp.CalledProcessError as e:
        print(e.stderr, file=sys.stderr)
        exit(1)


def get_recipes(package="*"):
    path = os.path.join(args.repository, "recipes", package)
    yield from map(os.path.dirname, glob.glob(os.path.join(path, "meta.yaml")))
    yield from map(os.path.dirname, glob.glob(os.path.join(path, "*", "meta.yaml")))


def test_recipes():
    if args.packages:
        recipes = [recipe for package in args.packages for recipe in get_recipes(package)]
    else:
        recipes = list(get_recipes())

    env_matrix = EnvMatrix(args.env_matrix)

    if not args.testonly:
        # filter out recipes that don't need to be build
        recipes = list(filter_recipes(recipes, env_matrix))

    # Build dag of recipes
    dag, name2recipes = get_dag(recipes)

    print("Packages to build", file=sys.stderr)
    print(*nx.nodes(dag), file=sys.stderr, sep="\n")

    subdags_n = int(os.environ.get("SUBDAGS", 1))
    subdag_i = int(os.environ.get("SUBDAG", 0))
    # Get connected subdags and sort by nodes
    if args.testonly:
        # use each node as a subdag (they are grouped into equal sizes below)
        subdags = sorted([[n] for n in nx.nodes(dag)])
    else:
        # take connected components as subdags
        subdags = sorted(map(sorted, nx.connected_components(dag.to_undirected())))
    # chunk subdags such that we have at most args.subdags many
    if subdags_n < len(subdags):
        chunks = [[n for subdag in subdags[i::subdags_n] for n in subdag]
                  for i in range(subdags_n)]
    else:
        chunks = subdags
    if subdag_i >= len(chunks):
        print("Nothing to be done.")
        return
    # merge subdags of the selected chunk
    subdag = dag.subgraph(chunks[subdag_i])
    # ensure that packages which need a build are built in the right order
    recipes = [recipe for package in nx.topological_sort(subdag) for recipe in name2recipes[package]]

    print("Building/testing subdag {} of recipes in order:".format(subdag_i), file=sys.stderr)
    print(*recipes, file=sys.stderr, sep="\n")

    if args.testonly:
        for recipe in recipes:
            yield build_recipe, recipe, env_matrix, True
    else:
        # build packages
        for recipe in recipes:
            yield build_recipe, recipe, env_matrix

        # upload builds
        if os.environ.get("TRAVIS_BRANCH") == "master" and os.environ.get(
            "TRAVIS_PULL_REQUEST") == "false":
            for recipe in recipes:
                packages = {
                    sp.run(["conda", "build", "--output", recipe],
                           stdout=sp.PIPE, env=env,
                           check=True).stdout.strip().decode()
                    for env in env_matrix
                }
                for package in packages:
                    if os.path.exists(package):
                        try:
                            sp.run(["anaconda", "-t",
                                    os.environ.get("ANACONDA_TOKEN"),
                                    "upload", package], stdout=sp.PIPE, stderr=sp.STDOUT, check=True)
                        except sp.CalledProcessError as e:
                            print(e.stdout.decode(), file=sys.stderr)
                            if b"already exists" in e.stdout:
                                # ignore error assuming that it is caused by existing package
                                pass
                            else:
                                raise e


if __name__ == "__main__":
    p = argparse.ArgumentParser(description="Build bioconda packages")
    p.add_argument("--env-matrix", required=True, help="Path to environment variable matrix.")
    p.add_argument("--repository",
                   default="/bioconda-recipes",
                   help="Path to checkout of bioconda recipes repository.")
    p.add_argument("--packages",
                   nargs="+",
                   help="A specific package to build.")
    p.add_argument("--testonly", action="store_true", help="Test packages instead of building.")
    p.add_argument("-v", "--verbose",
                   help="Make output more verbose for local debugging",
                   default=False,
                   action="store_true")

    global args
    args = p.parse_args()

    # Use a fixed conda-build from our fork
    sp.run(["pip", "install", "git+https://github.com/bioconda/conda-build.git@reintroduce-skip-existing"], check=True)
    #sp.run(["pip", "install", "git+https://github.com/bioconda/conda-build.git@20afe8250c617ab5bf3a3dcce89ea6d758b8851a"], check=True)

    sp.run(["gcc", "--version"], check=True)
    try:
        sp.run(["ldd", "--version"], check=True)
    except:
        pass

    nose.main(argv=sys.argv[:1], defaultTest="__main__")
