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
from docker import Client as DockerClient

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
@arg('--docker', nargs='?', metavar='URL', const='unix://var/run/docker.sock',
     help='Build packages in docker container (continuumio/conda_builder_linux).')
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
    if docker is not None:
        logger.debug("Setting up docker client v%s at %s", cfg['docker_client_version'], docker)
        docker = DockerClient(base_url=docker, version=cfg['docker_client_version'])

    success = utils.test_recipes(recipe_folder,
                                 config=config,
                                 packages=packages,
                                 testonly=testonly,
                                 force=force,
                                 docker=docker)
    exit(0 if success else 1)


@arg('repository', help='Path to top-level dir of repository')
@arg('--packages',
     nargs="+",
     help='Glob for package[s] to show in DAG. Default is to show all '
     'packages. Can be specified more than once')
@arg('--format', choices=['gml', 'dot'], help='Set format to print graph.')
@arg('--hide-singletons',
     action='store_true',
     help='Hide singletons in the printed graph.')
def dag(repository, packages="*", format='gml', hide_singletons=False):
    """
    Export the DAG of packages to a graph format file for visualization
    """
    dag = utils.get_dag(utils.get_recipes(repository, packages))[0]
    if hide_singletons:
        for node in nx.nodes(dag):
            if dag.degree(node) == 0:
                dag.remove_node(node)
    if format == 'gml':
        nx.write_gml(dag, sys.stdout.buffer)
    elif format == 'dot':
        write_dot(dag, sys.stdout)


@arg('repository', help='Path to top-level dir of repository')
@arg('--packages', nargs='+', help='Glob for packages to inspect (default is all)')
@arg('--dependencies', nargs='+', help='Return recipes with these dependencies')
def dependent(repository, packages="*", dependencies=None):
    """
    Print recipes dependent on a package
    """
    if dependencies is None:
        return

    d, n2r = utils.get_dag(utils.get_recipes(repository, packages), restrict=False)

    recipes = []
    for dep in dependencies:
        for i in d[dep]:
            recipes.extend(n2r[i])
    print('\n'.join(sorted(recipes)))




def main():
    argh.dispatch_commands([build, dag, dependent])
