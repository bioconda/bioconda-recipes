#!/usr/bin/env python

import sys
import os
import subprocess as sp

import yaml
import argh
from argh import arg
import networkx as nx
from nose.core import TextTestRunner

from . import utils

# NOTE:
#
# A package is the name of the software package, like `bowtie`.
#
# A recipe is the path to the recipe of one version of a package, like
# `recipes/bowtie` or `recipes/bowtie/1.0.1`.


@arg('repository', help='Path to top-level dir of repository')
@arg('--packages', nargs="+",
     help='Glob for package[s] to build. Default is to build all packages. Can '
     'be specified more than once')
@arg('--env-matrix', help='Path to yaml file specifying the environment matrix.')
@arg('--testonly', help='Test packages instead of building')
@arg('--verbose', help='Make output more verbose for local debugging')
@arg('--force', help='Force building the recipe even if it already exists in '
     'the bioconda channel')
def build(repository, packages="*", testonly=False, verbose=False,
          force=False):
    test_runner = TextTestRunner(verbosity=2 if verbose else 1)
    result = test_runner.run(utils.test_recipes(repository, packages=packages,
                                                testonly=testonly, verbose=verbose,
                                                force=force))
    sys.exit(not result.wasSuccessful())


@arg('repository', help='Path to top-level dir of repository')
#@arg('gml', help='Output GML file. If filename ends in .gz or .bz2 it will '
#     'be compressed')
@arg('--packages', nargs="+",
     help='Glob for package[s] to show in DAG. Default is to show all '
     'packages. Can be specified more than once')
@arg('--format', choices=['gml', 'dot'], help='Set format to print graph.')
@arg('--hide-singletons', action='store_true', help='Hide singletons in the printed graph.')
def dag(repository, packages="*", format='gml', hide_singletons=False):
    """
    Export the DAG of packages to a GML-format file for visualization
    """
    dag = utils.get_dag(utils.get_recipes(repository, packages))[0]
    if hide_singletons:
        for node in nx.nodes(dag):
            if dag.degree(node) == 0:
                dag.remove_node(node)
    if format == 'gml':
        nx.write_gml(dag, sys.stdout.buffer)
    elif format == 'dot':
        from networkx.drawing.nx_pydot import write_dot
        write_dot(dag, sys.stdout)

argh.dispatch_commands([build, dag])
