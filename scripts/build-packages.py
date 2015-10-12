#!/usr/bin/env python

import os
import glob
import subprocess as sp
import argparse
import sys

import nose

PYTHON_VERSIONS = ["27", "34"]


def build_recipe(recipe):
    try:
        os.environ["CONDA_NPY"] = "18"
        for py in PYTHON_VERSIONS:
            os.environ["CONDA_PY"] = py
            sp.check_output(["conda", "build", "--no-anaconda-upload",
                             "--skip-existing", "--quiet", recipe],
                            stderr=sp.STDOUT)
    except sp.CalledProcessError as e:
        print(e.output.decode())
        assert False


def test_recipes():
    if args.packages:
        recipes = [os.path.join(args.repository, "recipes", package)
                   for package in args.packages]
    else:
        recipes = list(glob.glob(os.path.join(args.repository, "recipes",
                                              "*")))

    for recipe in recipes:
        yield build_recipe, recipe

    if os.environ.get("TRAVIS_BRANCH") == "master" and os.environ.get(
        "TRAVIS_PULL_REQUEST") == "false":
        for recipe in recipes:
            packages = set()
            os.environ["CONDA_NPY"] = "18"
            for py in PYTHON_VERSIONS:
                os.environ["CONDA_PY"] = py
                packages.add(sp.check_output(["conda", "build", "--output",
                                              recipe]).strip())
            for package in packages:
                if os.path.exists(package):
                    try:
                        sp.check_call(["anaconda", "-t",
                                       os.environ.get("ANACONDA_TOKEN"),
                                       "upload", package])
                    except sp.CalledProcessError:
                        # ignore error assuming that it is caused by existing package
                        pass


if __name__ == "__main__":
    p = argparse.ArgumentParser(description="Build bioconda packages")
    p.add_argument("--repository",
                   default="/bioconda-recipes",
                   help="Path to checkout of bioconda recipes repository.")
    p.add_argument("--packages",
                   nargs="+",
                   help="A specific package to build.")

    global args
    args = p.parse_args()

    nose.main(argv=sys.argv[:1], defaultTest="__main__")
