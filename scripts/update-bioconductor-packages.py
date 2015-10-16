"""
New version of bioconductor? This script goes through each current Bioconductor
recipe, finds the corresponding dependencies that are also in this repo, and
reports the [reverse toplogically sorted] set of Bioconductor packages should
be updated using bioconductor-scraper.py.

In other words, the first items in the list should be updated and built first
since they are those that other packages are most dependent on.


Currently depends on networkx for the DAG and toplogical sort.
"""

import glob
import yaml
import pyaml
import os
import networkx as nx


def bioc_name(recipe_name):
    """
    Returns the Bioconductor name (rather than the sanitized lowercase bioconda
    name) that can be provided to bioconda-scraper.py
    """
    meta = os.path.join('recipes', recipe_name, 'meta.yaml')
    yml = yaml.load(open(meta))
    fn = yml['source']['fn']
    return fn.split('_')[0]


def dependencies(meta):
    """
    Given a meta.yaml file, return its depdencies that are in the current repo.
    """
    yml = yaml.load(open(meta))
    deps = list(set(yml['requirements']['build'] + yml['requirements']['run']))
    deps = [dep.split(' ')[0] for dep in deps]
    results = []
    for dep in deps:
        if (
            os.path.exists(os.path.join('recipes', dep)) and
            'bioconductor' in dep
        ):
            results.append(dep)
    return results


g = nx.DiGraph()

for meta in glob.glob('recipes/bioconductor-*/meta.yaml'):
    bioconda_name = os.path.basename(os.path.dirname(meta))
    for dep in dependencies(meta):
        g.add_edge(bioconda_name, dep)


for dep in nx.topological_sort(g, reverse=True):
    print(bioc_name(dep))
