#!/usr/bin/env python

import os
import glob
import subprocess as sp
import argparse
import sys
from collections import defaultdict
from itertools import chain

import networkx as nx
import nose
from conda_build.metadata import MetaData
from toposort import toposort_flatten

PYTHON_VERSIONS = ["27", "34", "35"]

os.environ.update({
    "CONDA_PERL": "5.22.0",
    "CONDA_BOOST": "1.60",
    "CONDA_NPY": "110"
})


def get_metadata(recipes):
    for recipe in recipes:
        print("Reading recipe", recipe, file=sys.stderr)
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

    dag = nx.Graph()
    dag.add_nodes_from(meta.get_value("package/name") for meta in metadata)
    for meta in metadata:
        name = meta.get_value("package/name")
        dag.add_edges_from((name, dep) for dep in set(get_inner_deps(chain(get_deps(meta), get_deps(meta, build=False)))))

    nx.relabel_nodes(dag, name2recipe, copy=False)
    return dag


def conda_index():
    index_dirs = [
        "/anaconda/conda-bld/linux-64",
        "/anaconda/conda-bld/osx-64",
    ]
    sp.run(["conda", "index"] + index_dirs, check=True, stdout=sp.PIPE)


def build_recipe(recipe):
    def build(py=None):
        try:
            out = None if args.verbose else sp.PIPE
            py = ["--python", py] if py is not None else []
            sp.run(["conda", "build", "--no-anaconda-upload"] + py +
                   ["--skip-existing", "--quiet", recipe],
                   stderr=out, stdout=out, check=True, universal_newlines=True,
                   env=os.environ)
            return True
        except sp.CalledProcessError as e:
            if e.stdout is not None:
                print(e.stdout)
                print(e.stderr)
            return False

    conda_index()
    if "python" not in get_deps(MetaData(recipe), build=False):
        success = build()
    else:
        # use list to enforce all builds
        success = all(list(map(build, PYTHON_VERSIONS)))

    if not success:
        # fail if all builds result in an error
        assert False, "At least one build of recipe {} failed.".format(recipe)


def filter_recipes(recipes):
    msgs = lambda py: [
        msg for msg in
        sp.run(
            ["conda", "build", "--python", py,
             "--skip-existing", "--output"] + recipes,
            check=True, stdout=sp.PIPE, universal_newlines=True, env=os.environ
        ).stdout.split("\n")
        if "Ignoring non-recipe" not in msg
    ][1:-1]
    skip = lambda msg: "already built, skipping" in msg or "defines build/skip" in msg

    for item in zip(recipes, *map(msgs, PYTHON_VERSIONS)):
        recipe = item[0]
        msg = item[1:]

        if all(map(skip, msg)):
            print("Skipping recipe", recipe, file=sys.stderr)
        else:
            yield recipe


def get_recipes(package="*"):
    path = os.path.join(args.repository, "recipes", package)
    yield from map(os.path.dirname, glob.glob(os.path.join(path, "meta.yaml")))
    yield from map(os.path.dirname, glob.glob(os.path.join(path, "*", "meta.yaml")))


def test_recipes():
    if args.packages:
        recipes = [recipe for package in args.packages for recipe in get_recipes(package)]
    else:
        recipes = list(get_recipes())
    # filter out recipes that don't need to be build
    recipes = list(filter_recipes(recipes))

    # Build dag of recipes
    dag = get_dag(recipes)
    subdags_n = os.environ.get("SUBDAGS", 1)
    subdag_i = os.environ.get("SUBDAG", 0)
    # Get connected subdags and sort by nodes
    subdags = sorted(connected_component_subgraphs(dag), key=lambda subdag: nx.nodes(subdag))
    # chunk subdags such that we have at most args.subdags many
    if subdags_n < len(subdags):
        k = len(subdags) // subdags_n
        chunks = [subdags[i:i+k] for i in range(0, subdags_n, k)]
    else:
        chunks = subdags
    if subdag_i >= len(chunks):
        print("Nothing to be done.")
        return
    subdag = nx.compose(*chunks[subdag_i])
    # ensure that packages which need a build are built in the right order
    recipes = nx.topological_sort(subdag)

    print("Building recipes in order:")
    print(*recipes, file=sys.stderr, sep="\n")

    # build packages
    for recipe in recipes:
        yield build_recipe, recipe

    # upload builds
    if os.environ.get("TRAVIS_BRANCH") == "master" and os.environ.get(
        "TRAVIS_PULL_REQUEST") == "false":
        for recipe in recipes:
            packages = set()
            for py in PYTHON_VERSIONS:
                packages.add(sp.run(["conda", "build", "--output",
                                     "--python",
                                     py, recipe], stdout=sp.PIPE, env=os.environ,
                                     check=True).stdout.strip().decode())
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
    p.add_argument("--repository",
                   default="/bioconda-recipes",
                   help="Path to checkout of bioconda recipes repository.")
    p.add_argument("--packages",
                   nargs="+",
                   help="A specific package to build.")
    p.add_argument("-v", "--verbose",
                   help="Make output more verbose for local debugging",
                   default=False,
                   action="store_true")

    global args
    args = p.parse_args()

    sp.run(["gcc", "--version"], check=True)
    try:
        sp.run(["ldd", "--version"], check=True)
    except:
        pass

    nose.main(argv=sys.argv[:1], defaultTest="__main__")
