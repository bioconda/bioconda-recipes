#!/usr/bin/env python

import os
import glob
import subprocess as sp
import argparse
import sys
import shutil
from collections import defaultdict, Iterable
from itertools import product, chain
import networkx as nx

from conda_build.metadata import MetaData
import yaml


DOCKER_IMAGE = "continuumio/conda_builder_linux:5.11-5.2-0-1"


def flatten_dict(dict):
    for key, values in dict.items():
        if isinstance(values, str) or not isinstance(values, Iterable):
            values = [values]
        yield [(key, value) for value in values]


def merged_env(env):
    _env = dict(os.environ)
    _env.update(env)
    return _env


class EnvMatrix:
    """
    Intended to be initialized with a YAML file and iterated over to yield all
    combinations of environments.

    YAML file has the following format::

        CONDA_PY:
          - "2.7"
          - "3.5"
        CONDA_BOOST: "1.60"
        CONDA_PERL: "5.22.0"
        CONDA_NPY: "110"
        CONDA_NCURSES: "5.9"
        CONDA_GSL: "1.16"

    """

    def __init__(self, path, verbose=False):
        self.verbose = verbose
        with open(path) as f:
            self.env = yaml.load(f)
            for key, val in self.env.items():
                if key != "CONDA_PY" and not isinstance(val, str):
                    raise ValueError(
                        "All versions except CONDA_PY must be strings.")

    def __iter__(self):
        """
        Given the YAML::

            CONDA_PY:
              - "2.7"
              - "3.5"
            CONDA_BOOST: "1.60"
            CONDA_NPY: "110"

        We get the following sets of env vars::

          [('CONDA_BOOST', '1.60'), ('CONDA_PY', '2.7'), ('CONDA_NPY', '110')]
          [('CONDA_BOOST', '1.60'), ('CONDA_PY', '3.5'), ('CONDA_NPY', '110')]

        A copy of the entire os.environ dict is updated and yielded for each of
        these sets.
        """
        for env in product(*flatten_dict(self.env)):
            yield env
            #e = dict(os.environ)
            #e.update(env)
            #yield e


def get_deps(recipe, build=True):
    """
    Generator of dependencies for a single recipe

    Only names (not versions) of dependencies are yielded.

    Parameters
    ----------
    recipe : str or MetaData
        If string, it is a path to the recipe; otherwise assume it is a parsed
        conda_build.metadata.MetaData instance.

    build : bool
        If True yield build dependencies, if False yield run dependencies.
    """
    if isinstance(recipe, str):
        metadata = MetaData(recipe)
    else:
        metadata = recipe
    for dep in metadata.get_value(
            "requirements/{}".format("build" if build else "run"), []):
        yield dep.split()[0]


def get_dag(recipes, blacklist=None):
    """
    Returns the DAG of recipe paths and a dictionary that maps package names to
    recipe paths. These recipe path values are lists and contain paths to all
    defined versions.

    Parameters
    ----------
    recipes : iterable
        An iterable of recipe paths, typically obtained via `get_recipes()`

    blacklist : set
        Package names to skip

    Returns
    -------
    dag : nx.DiGraph
        Directed graph of packages -- nodes are package names; edges are
        dependencies (both run and build dependencies)

    name2recipe : dict
        Dictionary mapping package names to recipe paths. These recipe path
        values are lists and contain paths to all defined versions.
    """
    recipes = list(recipes)
    metadata = [MetaData(recipe) for recipe in recipes]
    if blacklist is None:
        blacklist = set()

    # meta.yaml's package:name mapped to the recipe path
    name2recipe = defaultdict(list)
    for meta, recipe in zip(metadata, recipes):
        name = meta.get_value('package/name')
        if name not in blacklist:
            name2recipe[name].append(recipe)

    def get_inner_deps(dependencies):
        for dep in dependencies:
            name = dep.split()[0]
            if name in name2recipe:
                yield name

    dag = nx.DiGraph()
    dag.add_nodes_from(meta.get_value("package/name") for meta in metadata)
    for meta in metadata:
        name = meta.get_value("package/name")
        dag.add_edges_from((dep, name)
                           for dep in set(get_inner_deps(chain(
                               get_deps(meta),
                               get_deps(meta,
                                        build=False)))))

    #nx.relabel_nodes(dag, name2recipe, copy=False)
    return dag, name2recipe


def get_recipes(recipe_folder, package="*"):
    """
    Generator of recipes.

    Finds (possibly nested) directories containing a `meta.yaml` file.

    Parameters
    ----------
    recipe_folder : str
        Top-level dir of the recipes

    package : str or iterable
        Pattern or patterns to restrict the results.
    """
    if isinstance(package, str):
        package = [package]
    for p in package:
        path = os.path.join(recipe_folder, p)
        yield from map(os.path.dirname,
                       glob.glob(os.path.join(path, "meta.yaml")))
        yield from map(os.path.dirname,
                       glob.glob(os.path.join(path, "*", "meta.yaml")))


def filter_recipes(recipes, env_matrix):
    """
    Generator yielding only those recipes that do not already exist.

    Relies on `conda build --skip-existing` to determine if a recipe already
    exists.

    Parameters
    ----------
    recipes : iterable
        Iterable of candidate recipes

    env_matrix : EnvMatrix
    """

    def msgs(env):
        p = sp.run(
            ["conda", "build", "--skip-existing", "--output", "--dirty"
             ] + recipes,
            check=True,
            stdout=sp.PIPE,
            stderr=sp.PIPE,
            universal_newlines=True,
            env=merged_env(env))
        return [
            msg
            for msg in p.stdout.split("\n") if "Ignoring non-recipe" not in msg
        ][1:-1]
    skip = lambda msg: \
        "already built" in msg or "defines build/skip" in msg

    try:
        for item in zip(recipes, *map(msgs, env_matrix)):
            recipe = item[0]
            msg = item[1:]

            if not all(map(skip, msg)):
                yield recipe
    except sp.CalledProcessError as e:
        print(e.stderr, file=sys.stderr)
        exit(1)


def build(recipe,
          recipe_folder,
          env,
          verbose=False,
          testonly=False,
          force=False,
          docker=None):
    """
    Build a single recipe for a single env

    Parameters
    ----------
    recipe : str
        Path to recipe

    env : dict
        Environment (typically a single yielded dictionary from EnvMatrix
        instance)

    verbose : bool

    testonly : bool
        If True, skip building and instead run the test described in the
        meta.yaml.

    force : bool
        If True, the recipe will be built even if it already exists. Note that
        typically you'd want to bump the build number rather than force
        a build.
    """
    print("Building/testing", recipe, "for environment:")
    print(*('\t{}={}'.format(*i) for i in sorted(env)), sep="\n")
    build_args = []
    if testonly:
        build_args.append("--test")
    else:
        build_args += ["--no-anaconda-upload"]
    if not force:
        build_args += ["--skip-existing"]
    if docker is not None:
        conda_build_folder = os.path.join(os.path.dirname(os.path.dirname(shutil.which("conda"))), "conda-bld")
        recipe = os.path.relpath(recipe, recipe_folder)
        env = dict(env)
        env["ABI"] = 4
        container = docker.create_container(
            image=DOCKER_IMAGE,
            volumes=["/home/dev/recipes", "/opt/miniconda"],
            environment=env,
            command="bash /opt/share/internal_startup.sh "
                "conda build -c r -c bioconda --quiet recipes/{}".format(recipe),
            host_config=docker.create_host_config(binds={
                os.path.abspath(recipe_folder): {
                    "bind": "/home/dev/recipes",
                    "mode": "ro"
                },
                conda_build_folder: {
                    "bind": "/opt/miniconda/conda-bld",
                    "mode": "rw"
                }
            },
            network_mode="host"))
        cid = container["Id"]
        docker.start(container=cid)
        status = docker.wait(container=cid)
        if status != 0:
            print(docker.logs(container=cid, stdout=True, stderr=True).decode())
            return False
        return True
    else:
        try:
            out = None if verbose else sp.PIPE
            sp.run(["conda", "build", "--quiet", recipe] + build_args,
                   stderr=out,
                   stdout=out,
                   check=True,
                   universal_newlines=True,
                   env=merged_env(env))
            return True
        except sp.CalledProcessError as e:
            if e.stdout is not None:
                print(e.stdout)
                print(e.stderr)
            return False


def test_recipes(recipe_folder,
                 config,
                 packages="*",
                 testonly=False,
                 verbose=False,
                 force=False,
                 docker=None):
    """
    Build one or many bioconda packages.
    """
    config = load_config(config)
    env_matrix = EnvMatrix(config['env_matrix'], verbose=verbose)
    blacklist = get_blacklist(config['blacklists'])

    if verbose:
        print('blacklist:', blacklist)

    print("Filtering recipes...")

    if packages == "*":
        packages = ["*"]
    recipes = [
        recipe
        for package in packages
        for recipe in get_recipes(recipe_folder, package)
    ]
    if not recipes:
        print("Nothing to be done.")
        return

    if not force:
        recipes = list(filter_recipes(recipes, env_matrix))

    env_matrix.verbose = verbose

    dag, name2recipes = get_dag(recipes, blacklist=blacklist)

    if not dag:
        print("Nothing to be done.")
        return True
    else:
        print("Building/testing", len(dag), "recipes in total.")

    subdags_n = int(os.environ.get("SUBDAGS", 1))
    subdag_i = int(os.environ.get("SUBDAG", 0))

    # Get connected subdags and sort by nodes
    if testonly:
        # use each node as a subdag (they are grouped into equal sizes below)
        subdags = sorted([[n] for n in nx.nodes(dag)])
    else:
        # take connected components as subdags
        subdags = sorted(map(sorted, nx.connected_components(dag.to_undirected(
        ))))
    # chunk subdags such that we have at most subdags_n many
    if subdags_n < len(subdags):
        chunks = [[n for subdag in subdags[i::subdags_n] for n in subdag]
                  for i in range(subdags_n)]
    else:
        chunks = subdags
    if subdag_i >= len(chunks):
        print("Nothing to be done.")
        return True
    # merge subdags of the selected chunk
    subdag = dag.subgraph(chunks[subdag_i])
    # ensure that packages which need a build are built in the right order
    recipes = [recipe
               for package in nx.topological_sort(subdag)
               for recipe in name2recipes[package]]

    print("Building/testing subdag", subdag_i, "of", subdags_n, " (",
          len(recipes), "recipes).")

    if docker is not None:
        print('Pulling docker image...')
        docker.pull(DOCKER_IMAGE)
        print('Done.')

    success = True
    for recipe in recipes:
        envs = iter(env_matrix)
        # Use only first envionment if package does not depend on Python.
        if "python" not in get_deps(recipe):
            envs = [next(envs)]
        for env in envs:
            success |= build(recipe,
                             recipe_folder,
                             env,
                             verbose,
                             testonly,
                             force,
                             docker=docker)
            conda_index(config)

    if not testonly:
        # upload builds
        if (os.environ.get("TRAVIS_BRANCH") == "master" and
                os.environ.get("TRAVIS_PULL_REQUEST") == "false"):
            for recipe in recipes:
                packages = {
                    sp.run(
                        ["conda", "build", "--output", "--dirty", recipe],
                        stdout=sp.PIPE,
                        env=merged_env(env),
                        check=True).stdout.strip().decode()
                    for env in env_matrix
                }
                for package in packages:
                    if os.path.exists(package):
                        try:
                            sp.run(
                                ["anaconda", "-t",
                                 os.environ.get("ANACONDA_TOKEN"), "upload",
                                 package],
                                stdout=sp.PIPE,
                                stderr=sp.STDOUT,
                                check=True)
                        except sp.CalledProcessError as e:
                            print(e.stdout.decode(), file=sys.stderr)
                            if b"already exists" in e.stdout:
                                # ignore error assuming that it is caused by
                                # existing package
                                pass
                            else:
                                raise e
    return success


def conda_index(config):
    if config['index_dirs']:
        sp.run(['conda', 'index'] + config['index_dirs'],
               check=True,
               stdout=sp.PIPE)


def get_blacklist(blacklists):
    "Return list of recipes to skip from blacklists"
    blacklist = set()
    for p in blacklists:
        blacklist.update([i.strip() for i in open(p) if not i.startswith('#')])
    return blacklist


def load_config(path):
    relpath = lambda p: os.path.relpath(p, os.path.dirname(path))
    config = yaml.load(open(path))

    def get_list(key):
        # always return empty list, also if NoneType is defined in yaml
        value = config.get(key)
        if value is None:
            return []
        return value

    config['env_matrix'] = relpath(config['env_matrix'])
    config['blacklists'] = [relpath(p) for p in get_list('blacklists')]
    config['index_dirs'] = [relpath(p) for p in get_list('index_dirs')]
    return config
