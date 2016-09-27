#!/usr/bin/env python

import sys
import os
import subprocess as sp
from functools import partial
import shlex
import logging

import yaml
import argh
from argh import arg
import networkx as nx
from networkx.drawing.nx_pydot import write_dot

from . import utils

# NOTE:
#
# A package is the name of the software package, like `bowtie`.
#
# A recipe is the path to the recipe of one version of a package, like
# `recipes/bowtie` or `recipes/bowtie/1.0.1`.


@arg('recipe_folder', help='Path to top-level dir of recipes.')
@arg('config', help='Path to yaml file specifying the configuration')
@arg(
    '--packages',
    nargs="+",
    help='Glob for package[s] to build. Default is to build all packages. Can '
    'be specified more than once')
@arg('--testonly', help='Test packages instead of building')
@arg('--force',
     help='Force building the recipe even if it already exists in '
     'the bioconda channel')
@arg('--docker', action='store_true',
     help='Build packages in docker container.')
@arg('--loglevel', help="Set logging level (debug, info, warning, error, critical)")
def build(recipe_folder,
          config,
          packages="*",
          testonly=False,
          force=False,
          docker=None,
          loglevel="warning",
          ):

    logging.basicConfig(format="%(asctime)s:%(levelname)s:%(name)s:%(message)s", level=getattr(logging, loglevel.upper()))
    logger = logging.getLogger(__name__)
    cfg = utils.load_config(config)
    setup = cfg.get('setup', None)
    if setup:
        logger.debug("Running setup: %s" % setup)
        for cmd in setup:
            sp.run(shlex.split(cmd))

    success = utils.test_recipes(recipe_folder,
                                 config=config,
                                 packages=packages,
                                 testonly=testonly,
                                 force=force,
                                 docker=docker)
    exit(0 if success else 1)


@arg('recipe_folder', help='Path to recipes directory')
@arg('--packages',
     nargs="+",
     help='Glob for package[s] to show in DAG. Default is to show all '
     'packages. Can be specified more than once')
@arg('--format', choices=['gml', 'dot'], help='Set format to print graph.')
@arg('--hide-singletons',
     action='store_true',
     help='Hide singletons in the printed graph.')
def dag(recipe_folder, packages="*", format='gml', hide_singletons=False):
    """
    Export the DAG of packages to a graph format file for visualization
    """
    dag = utils.get_dag(utils.get_recipes(recipe_folder, packages))[0]
    if hide_singletons:
        for node in nx.nodes(dag):
            if dag.degree(node) == 0:
                dag.remove_node(node)
    if format == 'gml':
        nx.write_gml(dag, sys.stdout.buffer)
    elif format == 'dot':
        write_dot(dag, sys.stdout)


@arg('recipe_folder', help='Path to recipes directory')
@arg('--packages', nargs='+', help='Glob for packages to inspect (default is all)')
@arg('--dependencies', nargs='+', help='Return recipes with these dependencies')
@arg('--loglevel', help="Set logging level (debug, info, warning, error, critical)")
def dependent(recipe_folder, packages="*", dependencies=None, loglevel='warning'):
    """
    Print recipes dependent on a package
    """
    logging.basicConfig(format="%(asctime)s:%(levelname)s:%(name)s:%(message)s", level=getattr(logging, loglevel.upper()))
    logger = logging.getLogger(__name__)
    if dependencies is None:
        return

    d, n2r = utils.get_dag(utils.get_recipes(recipe_folder, packages), restrict=False)

    recipes = []
    for dep in dependencies:
        for i in nx.algorithms.descendants(d, dep):
            for r in n2r[i]:
                recipes.append(r)
    print('\n'.join(sorted(recipes)))


def main():
    argh.dispatch_commands([build, dag, dependent])
