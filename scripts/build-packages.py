#!/usr/bin/env python

import os
import glob
import subprocess as sp

import nose


def build_recipe(recipe):
    assert sp.call(["conda", "build", "--no-anaconda-upload",
                    "--skip-existing", recipe]) == 0


def test_recipes():
    p = argparse.ArgumentParser(description="Build bioconda packages")
    p.add_argument("repository",
                   help="Path to checkout of bioconda recipes repository.")
    p.add_argument("--packages",
                   nargs="+",
                   help="A specific package to build.")

    args = p.parse_args()

    packages = []

    if args.packages:
        packages = args.packages
    elif os.environ("TRAVIS_OS_NAME") == "osx":
        packages = open(os.path.join(args.repository,
                                     "osx-whitelist.txt")).readlines()

    if packages:
        recipes = [os.path.join(args.repository, "recipes", package)
                   for package in packages]
    else:
        recipes = glob.glob(os.path.join(args.repository, "recipes", "*"))

    for recipe in recipes:
        yield build_recipe, recipe

    if os.environ("TRAVIS_BRANCH") == "master" and os.environ(
        "TRAVIS_PULL_REQUEST") == "false":
        sp.call(["anaconda", "-t", os.environ("ANACONDA_TOKEN"), "upload",
                 "/tmp/conda-build/anaconda/conda-bld/{}-64/*.tar.bz2".format(
                     os.environ("TRAVIS_OS_NAME"))])


if __name__ == "__main__":
    nose.run(defaultTest=__name__)
