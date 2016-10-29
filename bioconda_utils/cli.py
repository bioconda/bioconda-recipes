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
from .build import build_recipes
from . import docker_utils

logger = logging.getLogger(__name__)
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
@arg('--mulled-test', action='store_true', help="Run a mulled-build test on the built package")
@arg('--build_script_template', help='''Filename to optionally replace build
     script template used by the Docker container. By default use
     docker_utils.BUILD_SCRIPT_TEMPLATE. Only used if --docker is True.''')
@arg('--pkg_dir', help='''Specifies the directory to which container-built
     packages should be stored on the host. Default is to use the host's
     conda-bld dir. If --docker is not specified, then this argument is
     ignored.''')
@arg('--conda-build-version',
     help='''Version of conda-build to use if building
     in a docker container. Has no effect otherwise.''')
@arg('--quick', help='''To speed up filtering, do not consider any recipes that
     are > 2 days older than the latest commit to master branch.''')
def build(recipe_folder,
          config,
          packages="*",
          testonly=False,
          force=False,
          docker=None,
          loglevel="info",
          mulled_test=False,
          build_script_template=None,
          pkg_dir=None,
          conda_build_version=docker_utils.DEFAULT_CONDA_BUILD_VERSION,
          quick=False,
          ):
    LEVEL = getattr(logging, loglevel.upper())
    logging.basicConfig(level=LEVEL, format='%(levelname)s:%(name)s:%(message)s')
    logging.getLogger('bioconda_utils').setLevel(getattr(logging, loglevel.upper()))
    cfg = utils.load_config(config)
    setup = cfg.get('setup', None)
    if setup:
        logger.debug("Running setup: %s" % setup)
        for cmd in setup:
            utils.run(shlex.split(cmd))
    if docker:
        if build_script_template is not None:
            build_script_template = open(build_script_template).read()
        else:
            build_script_template = docker_utils.BUILD_SCRIPT_TEMPLATE
        if pkg_dir is None:
            use_host_conda_bld = True
        else:
            use_host_conda_bld = False

        docker_builder = docker_utils.RecipeBuilder(
            build_script_template=build_script_template,
            pkg_dir=pkg_dir,
            use_host_conda_bld=use_host_conda_bld,
            conda_build_version=conda_build_version,
        )
    else:
        docker_builder = None

    success = build_recipes(recipe_folder,
                                 config=config,
                                 packages=packages,
                                 testonly=testonly,
                                 force=force,
                                 mulled_test=mulled_test,
                                 docker_builder=docker_builder,
                                 quick=quick,
                            )
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
@arg('--dependencies', nargs='+',
     help='''Return recipes in `recipe_folder` in the dependency chain for the
     packages listed here. Answers the question "what does PACKAGE need?"''')
@arg('--reverse-dependencies', nargs='+',
     help='''Return recipes in `recipe_folder` in the reverse dependency chain
     for packages listed here. Answers the question "what depends on
     PACKAGE?"''')
@arg('--restrict',
     help='''Restrict --dependencies to packages in `recipe_folder`. Has no
     effect if --reverse-dependencies, which always looks just in the recipe
     dir.''')
@arg('--loglevel', help="Set logging level (debug, info, warning, error, critical)")
def dependent(recipe_folder, restrict=False, dependencies=None, reverse_dependencies=None, loglevel='warning'):
    """
    Print recipes dependent on a package
    """
    if dependencies and reverse_dependencies:
        raise ValueError(
            '`dependencies` and `reverse_dependencies` are mutually exclusive')

    LEVEL = getattr(logging, loglevel.upper())
    logging.basicConfig(level=LEVEL, format='%(levelname)s:%(name)s:%(message)s')
    logging.getLogger('bioconda_utils').setLevel(getattr(logging, loglevel.upper()))

    d, n2r = utils.get_dag(utils.get_recipes(recipe_folder, "*"), restrict=restrict)

    if reverse_dependencies is not None:
        func, packages = nx.algorithms.descendants, reverse_dependencies
    elif dependencies is not None:
        func, packages = nx.algorithms.ancestors, dependencies

    pkgs = []
    for pkg in packages:
        pkgs.extend(list(func(d, pkg)))
    print('\n'.join(sorted(pkgs)))


def main():
    argh.dispatch_commands([build, dag, dependent])
