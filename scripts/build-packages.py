#!/usr/bin/env python

import os
import glob
import subprocess as sp
import argparse
import sys
from collections import defaultdict
from itertools import chain

import nose
from conda_build.metadata import MetaData
from toposort import toposort_flatten
import helpers


PYTHON_VERSIONS = ["27", "34", "35"]
CONDA_NPY = "110"
CONDA_PERL = "5.22.0"

# Passing `--perl 5.22.0` to conda-build fails (apparently due to
# version parsing errors?), but setting the CONDA_PERL env var
# works.
env = os.environ
env.update({'CONDA_PERL': CONDA_PERL})


def get_metadata(recipes):
    for recipe in recipes:
        print("Reading recipe", recipe, file=sys.stderr)
        yield MetaData(recipe)


def get_deps(metadata, build=True):
    for dep in metadata.get_value("requirements/{}".format("build" if build else "run"), []):
        yield dep.split()[0]


# inspired by conda-build-all from https://github.com/omnia-md/conda-recipes
def toposort_recipes(recipes):
    print('toposorting', recipes)
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
    return [recipe for name in toposort_flatten(dag) for recipe in name2recipe[name]]


def conda_index():
    print('indexing')
    index_dirs = [
        "/anaconda/conda-bld/linux-64",
        "/anaconda/conda-bld/osx-64",
    ]
    sp.run(["conda", "index"] + index_dirs, check=True, stdout=sp.PIPE)


def build_recipe(recipe, py):
    def build(py=None):
        try:
            out = None if args.verbose else sp.PIPE
            py = ["--python", py, "--numpy", CONDA_NPY] if py is not None else []
            sp.run(["conda", "build", "--no-anaconda-upload"] + py +
                   ["--skip-existing", "--quiet", recipe],
                   stderr=out, stdout=out, check=True, universal_newlines=True,
                   env=env)
            return True
        except sp.CalledProcessError as e:
            if e.stdout is not None:
                print(e.stdout)
                print(e.stderr)
            return False

    conda_index()
    if "python" not in get_deps(MetaData(recipe), build=False):
        success = build()
    else:
        success = build(py)

    if not success:
        # fail if all builds result in an error
        assert False, "Recipe {0} failed.".format(recipe)


def filter_recipes(recipes, py):
    print(recipes, file=sys.stderr)
    for recipe in recipes:
        if helpers.should_skip(recipe, py):
            print("Skipping recipe (defines skip for py{})".format(py), recipe, file=sys.stderr)
            continue
        msg = sp.run(
            ["conda", "build", "--numpy", CONDA_NPY, "--python", py,
             "--skip-existing", "--output", recipe],
            check=True, stdout=sp.PIPE, universal_newlines=True
        ).stdout.split("\n")
        if any('already built, skipping' in m for m in msg):
            print("Skipping recipe (already built)", py, recipe, file=sys.stderr)
            continue
        elif any('Ignoring non-recipe' in m for m in msg):
            continue

        yield recipe


def get_recipes(package="*"):
    print("getting recipes")
    sys.stdout.flush()
    path = os.path.join(args.repository, "recipes", package)
    yield from map(os.path.dirname, glob.glob(os.path.join(path, "meta.yaml")))
    yield from map(os.path.dirname, glob.glob(os.path.join(path, "*", "meta.yaml")))


def test_recipes():
    if args.packages:
        recipes = [recipe for package in args.packages for recipe in get_recipes(package)]
    else:
        recipes = list(get_recipes())

    for py in PYTHON_VERSIONS:
        # ensure that packages which need a build are built in the right order
        recipes = toposort_recipes(list(filter_recipes(recipes, py)))
        print(py, recipes)

        # build packages
        for recipe in recipes:
            yield build_recipe, recipe, py

    # upload builds
    if os.environ.get("TRAVIS_BRANCH") == "master" and os.environ.get(
        "TRAVIS_PULL_REQUEST") == "false":
        for recipe in recipes:
            packages = set()
            for py in PYTHON_VERSIONS:
                packages.add(sp.run(["conda", "build", "--output",
                                     "--numpy", CONDA_NPY, "--python",
                                     py, recipe], stdout=sp.PIPE,
                                     check=True).stdout.strip().decode())
            for package in packages:
                if os.path.exists(package):
                    try:
                        sp.run(["anaconda", "-t",
                                os.environ.get("ANACONDA_TOKEN"),
                                "upload", package], stdout=sp.PIPE, stderr=sp.STDOUT, check=True)
                    except sp.CalledProcessError as e:
                        print(e.stdout.decode(), file=sys.stderr)
                        if b"already exists" in e.stdout:
                            # ignore error assuming that it is caused by existing package
                            pass
                        else:
                            raise e


if __name__ == "__main__":
    p = argparse.ArgumentParser(description="Build bioconda packages")
    p.add_argument("--repository",
                   default="/bioconda-recipes",
                   help="Path to checkout of bioconda recipes repository.")
    p.add_argument("--packages",
                   nargs="+",
                   help="A specific package to build.")
    p.add_argument("-v", "--verbose",
                   help="Make output more verbose for local debugging",
                   default=False,
                   action="store_true")

    global args
    args = p.parse_args()

    sp.run(["gcc", "--version"], check=True)
    try:
        sp.run(["ldd", "--version"], check=True)
    except:
        pass

    nose.main(argv=sys.argv[:1], defaultTest="__main__")
