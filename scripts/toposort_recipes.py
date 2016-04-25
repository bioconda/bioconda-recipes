#!/usr/bin/env python

"""
This script can be useful when creating a large number of recipes that, if
submitted all at once, could result in timeout errors when building on
travis-ci. A common example is when recipes must be updated for a new
Bioconductor release. This script batches together recipes such that each batch
does not depend on any recipes in subsequent batches.

For example, upon updating recipes for a new version of bioconductor, find all
the relevant recipes:

    ./toposort_recipes.py | grep -E "^bioconductor-|^r-|^---"

Then grab everything up to the first "---" (this is the first batch) and commit
them. Then submit a PR for travis-ci to try testing these packages. Rinse and
repeat using subsequent batches.

*TODO:* refactor these functions, which are shared with build-packages.py, into
a separate module.
"""
from __future__ import print_function
import os
from conda_build.metadata import MetaData
from toposort import toposort_flatten, toposort
import glob
import sys
from collections import defaultdict
from itertools import chain


def get_metadata(recipes):
    for recipe in recipes:
        print("Reading recipe", recipe, file=sys.stderr)
        yield MetaData(recipe)


def get_deps(metadata, build=True):
    for dep in metadata.get_value("requirements/{}".format("build" if build else "run"), []):
        yield dep.split()[0]


# inspired by conda-build-all from https://github.com/omnia-md/conda-recipes
def toposort_recipes(recipes):
    metadata = list(get_metadata(recipes))

    name2recipe = defaultdict(list)
    for meta, recipe in zip(metadata, recipes):
        name2recipe[meta.get_value("package/name")].append(recipe)

    def get_inner_deps(dependencies):
        for dep in dependencies:
            name = dep.split()[0]
            if name in name2recipe:
                yield name

    dag = {
        meta.get_value("package/name"): set(get_inner_deps(chain(get_deps(meta), get_deps(meta, build=False))))
        for meta in metadata
    }
    # note difference here from build-packages.py
    return toposort(dag)


def get_recipes(repository, package="*"):
    path = os.path.join(repository, "recipes", package)
    yield from map(os.path.dirname, glob.glob(os.path.join(path, "meta.yaml")))
    yield from map(os.path.dirname, glob.glob(os.path.join(path, "*", "meta.yaml")))


if __name__ == "__main__":
    for i in toposort_recipes(list(get_recipes('../', '*'))):
        for j in i:
            print(j)
        print('---')

