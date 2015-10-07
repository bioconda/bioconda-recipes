#!/usr/bin/env python

import os
import glob
import subprocess as sp
import argparse
import sys

import nose


def build_recipe(recipe):
    try:
        sp.check_output(["conda", "build", "--no-anaconda-upload",
                    "--skip-existing", recipe], stderr=sp.STDOUT)
    except sp.CalledProcessError as e:
        print(e.output)
        assert False


def test_recipes():
    packages = []

    if args.packages:
        packages = args.packages
    elif os.environ.get("TRAVIS_OS_NAME") == "osx":
        packages = [l.strip() for l in open(os.path.join(args.repository,
                                            "osx-whitelist.txt"))]

    if packages:
        recipes = [os.path.join(args.repository, "recipes", package)
                   for package in packages]
    else:
        recipes = glob.glob(os.path.join(args.repository, "recipes", "*"))

    for recipe in recipes:
        yield build_recipe, recipe

    if os.environ.get("TRAVIS_BRANCH") == "master" and os.environ.get(
        "TRAVIS_PULL_REQUEST") == "false":
        sp.call(["anaconda", "-t", os.environ.get("ANACONDA_TOKEN"), "upload",
                 "/tmp/conda-build/anaconda/conda-bld/{}-64/*.tar.bz2".format(
                     os.environ.get("TRAVIS_OS_NAME"))])


if __name__ == "__main__":
    p = argparse.ArgumentParser(description="Build bioconda packages")
    p.add_argument("repository",
                   help="Path to checkout of bioconda recipes repository.")
    p.add_argument("--packages",
                   nargs="+",
                   help="A specific package to build.")

    global args
    args = p.parse_args()

    nose.main(argv=sys.argv[:1], defaultTest="__main__")
