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
            e = dict(os.environ)
            if self.verbose:
                print(
                    'environment:',
                    ','.join(['='.join(i) for i in sorted(env)])
                )
            e.update(env)
            yield e


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
        "requirements/{}".format("build" if build else "run"), []
    ):
        yield dep.split()[0]


def get_dag(recipes):
    """
    Returns the DAG of recipe paths and a dictionary that maps package names to
    recipe paths. These recipe path values are lists and contain paths to all
    defined versions.

    Parameters
    ----------
    recipes : iterable
        An iterable of recipe paths, typically obtained via `get_recipes()`

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

    # meta.yaml's package:name mapped to the recipe path
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
        dag.add_edges_from(
            (dep, name) for dep in set(
                get_inner_deps(
                    chain(
                        get_deps(meta), get_deps(meta, build=False)
                    )
                )
            )
        )

    #nx.relabel_nodes(dag, name2recipe, copy=False)
    return dag, name2recipe


def toposort_recipes(repository, only_modified=False, subset="*"):
    """
    Topologically sort recipes

    Parameters
    ----------
    repository : str
        Top-level directory of the repository

    only_modified : bool
        If True, then use `git status` to identify which recipes have changed.
        `subset` will also be applied to these recipes.

    subset : str or iterable
        Pattern or patterns to restrict toposorted recipes (e.g.,
        ['bioconductor-*', 'r-*']).
    """
    recipes = list(get_recipes(repository, subset))
    if only_modified:
        status = sp.check_output(
            ['git', 'status'], cwd=repository, universal_newlines=True)

        def modified(f):
            "True for files reported by git to be modified"
            return ('\tmodified:' in f) and ('recipes/' in f)

        def recipe_name(f):
            "extract recipe name from a 'modified:' line in git status"
            toks = f.split('modified:')[-1].strip().split(os.path.sep)
            recipes_idx = toks.index('recipes')
            return toks[recipes_idx + 1]

        modified = get_recipes(
            repository,
            set(
                map(
                    recipe_name,
                    filter(
                        modified,
                        status.splitlines()
                    )
                )
            )
        )
        recipes = set(modified).intersection(recipes)

    dag, name2recipe = get_dag(recipes)
    subdags = sorted(map(list, nx.connected_components(dag.to_undirected())))
    for subdag in subdags:
        yield nx.topological_sort(dag.subgraph(subdag))


def get_recipes(repository, package="*"):
    """
    Generator of recipes.

    Finds (possibly nested) directories containing a `meta.yaml` file.

    Parameters
    ----------
    repository : str
        Top-level dir of the repository

    package : str or iterable
        Pattern or patterns to restrict the results.
    """
    if isinstance(package, str):
        package = [package]
    for p in package:
        path = os.path.join(repository, "recipes", p)
        yield from map(
            os.path.dirname, glob.glob(os.path.join(path, "meta.yaml")))
        yield from map(
            os.path.dirname, glob.glob(os.path.join(path, "*", "meta.yaml")))


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
            ["conda", "build", "--skip-existing", "--output"] + recipes,
            check=True, stdout=sp.PIPE, stderr=sp.PIPE,
            universal_newlines=True, env=env
        )
        return [
            msg for msg in p.stdout.split("\n")
            if "Ignoring non-recipe" not in msg][1:-1]
    skip = lambda msg: \
        "already built, skipping" in msg or "defines build/skip" in msg

    try:
        for item in zip(recipes, *map(msgs, env_matrix)):
            recipe = item[0]
            msg = item[1:]

            if not all(map(skip, msg)):
                yield recipe
    except sp.CalledProcessError as e:
        print(e.stderr, file=sys.stderr)
        exit(1)


def build(recipe, env, verbose=False, testonly=False, force=False):
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
    try:
        out = None if verbose else sp.PIPE
        build_args = []
        if testonly:
            build_args.append("--test")
        else:
            build_args += ["--no-anaconda-upload"]
        if not force:
            build_args += ["--skip-existing"]
        sp.run(["conda", "build", "--quiet", recipe] + build_args,
               stderr=out, stdout=out, check=True, universal_newlines=True,
               env=env)
        return True
    except sp.CalledProcessError as e:
        if e.stdout is not None:
            print(e.stdout)
            print(e.stderr)
        return False


def index_dirs(dirs):
    if all(map(os.path.exists, index_dirs)):
        sp.run(["conda", "index"] + index_dirs, check=True, stdout=sp.PIPE)


def _index_dirs_from_config(config):
    index_dirs(yaml.load(open(config))['index_dirs'])


def _env_matrix_from_config(config, verbose=False):
    "Returns EnvMatrix from env_matrix.yaml path relative to config path."
    cfg = yaml.load(open(config))
    return EnvMatrix(
        os.path.relpath(cfg['env_matrix'], os.path.dirname(config)),
        verbose=verbose)


def run_setup_from_config(config):
    cfg = yaml.load(open(config))
    for cmd in cfg['setup']:
        sp.run(cmd.split(), check=True)
