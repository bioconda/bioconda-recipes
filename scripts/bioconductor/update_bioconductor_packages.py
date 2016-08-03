"""
New version of bioconductor? This script goes through each current Bioconductor
recipe, finds the corresponding dependencies that are also in this repo, and
reports the [reverse toplogically sorted] set of Bioconductor packages that
should be updated using bioconductor-scraper.py.

In other words, the first items in the list should be updated and built first
since they are those that other packages are most dependent on.

Outputs strings of the format BioconductorName:recipename
"""

import glob
import yaml
import pyaml
import os
import networkx as nx
import itertools
from conda_build.metadata import MetaData
from conda import version
import sys
sys.path.insert(0, '..')
import utils


def bioc_name(recipe):
    """
    Returns the Bioconductor name (rather than the sanitized lowercase bioconda
    name) that can be provided to bioconda-scraper.py
    """
    return MetaData(recipe).meta['source']['fn'].split('_')[0]


if __name__ == "__main__":
    import argparse
    ap = argparse.ArgumentParser()
    ap.add_argument('--repository', default='recipes', help='Recipes directory')
    args = ap.parse_args()

    recipes = list(utils.get_recipes(args.repository, 'bioconductor-*'))
    deps = itertools.chain(
        itertools.chain(*(utils.get_deps(i, build=True) for i in recipes)),
        itertools.chain(*(utils.get_deps(i, build=False) for i in recipes))
    )

    deps = list(filter(lambda x: x.startswith(('r-', 'bioconductor-')), deps))

    bioconda_deps = list(
        filter(
            lambda x: os.path.isdir(x),
            itertools.chain(*(utils.get_recipes(args.repository, i) for i in deps))
        )
    )

    dag, name2recipe = utils.get_dag(bioconda_deps)

    def version_sort(x):
        return version.VersionOrder(MetaData(x).meta['package']['version'])

    for name in nx.topological_sort(dag):
        recipe = sorted(name2recipe[name], key=version_sort)[-1]
        print('{0}:{1}'.format(bioc_name(recipe), name))
