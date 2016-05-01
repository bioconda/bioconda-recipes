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
    Class for updating environment variables based on combinations listed
    in a YAML file.
    """
    def __init__(self, path):
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

        A copy of os.environ updated and yielded for each of these sets.
        """
        for env in product(*flatten_dict(self.env)):
            e = dict(os.environ)
            e.update(env)
            yield e


def get_deps(recipe, build=True):
    """
    Generator of dependencies for a single recipe, which can be specified as
    a path or as a parsed MetaData.

    Only names (not versions) of dependencies are yielded. Use `build=True` to
    yield build dependencies, otherwise yield run dependencies.
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
    `recipes` is an iterable of recipe paths.

    Returns the DAG of recipe paths and a dictionary that maps package names to
    recipe paths. These recipe path values are lists and contain paths to all
    defined versions.
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



def get_recipes(repository, package="*"):
    """
    Generator of all recipes matching the pattern `package`.

    `package` can also be an iterable of patterns.

    `repository` is the top-level directory of the repo which is expected to
    have a "recipes" subdirectory.
    """
    if isinstance(package, str):
        package = [package]
    for p in package:
        path = os.path.join(repository, "recipes", p)
        yield from map(os.path.dirname, glob.glob(os.path.join(path, "meta.yaml")))
        yield from map(os.path.dirname, glob.glob(os.path.join(path, "*", "meta.yaml")))
