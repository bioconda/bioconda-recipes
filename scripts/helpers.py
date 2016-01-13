#!/usr/bin/env python
import sys
from collections import defaultdict
from itertools import chain
import re
import os
import glob
from conda_build import metadata
import conda.config as cc
from conda_build.config import config
from conda_build.metadata import MetaData
from toposort import toposort_flatten
import subprocess as sp
import yaml


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
    return [recipe for name in toposort_flatten(dag) for recipe in name2recipe[name]]


def filter_recipes(recipes, py, CONDA_NPY):
    for recipe in recipes:
        if should_skip(recipe, py):
            print("Skipping recipe (defines skip for py{})".format(py), recipe, file=sys.stderr)
            continue
        msg = sp.run(
            ["conda", "build", "--numpy", CONDA_NPY, "--python", py,
             "--skip-existing", "--output", recipe],
            check=True, stdout=sp.PIPE, universal_newlines=True
        ).stdout.split("\n")
        if 'already built, skipping' in msg:
            print("Skipping recipe (already built)", recipe, file=sys.stderr)
            continue
        if 'Ignoring non-recipe' in msg:
            continue
        yield recipe


def get_recipes(package="*", repository="."):
    path = os.path.join(repository, "recipes", package)
    yield from map(os.path.dirname, glob.glob(os.path.join(path, "meta.yaml")))
    yield from map(os.path.dirname, glob.glob(os.path.join(path, "*", "meta.yaml")))



def build_recipe(recipe, py, CONDA_NPY, verbose=True, env=None):
    if env is None:
        env = {}
    def build(py=None):
        try:
            out = None if verbose else sp.PIPE
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

    if "python" not in get_deps(MetaData(recipe), build=False):
        success = build()
    else:
        success = build(py)

    if not success:
        # fail if all builds result in an error
        assert False, "Recipe {0} failed.".format(recipe)


sel_pat = re.compile(r'(.+?)\s*(#.*)?\[(.+)\](?(2).*)$')
def should_skip(recipe, py, np=None, pl=None):
    # modified from conda_build.metadata.select_lines() and
    # conda_build.metadata.ns_cfg()

    plat = cc.subdir
    if np is None:
        np = config.CONDA_NPY
    if pl is None:
        pl = config.CONDA_PERL
    py = int(py)
    assert isinstance(py, int), py
    namespace = dict(
        linux = plat.startswith('linux-'),
        linux32 = bool(plat == 'linux-32'),
        linux64 = bool(plat == 'linux-64'),
        arm = plat.startswith('linux-arm'),
        osx = plat.startswith('osx-'),
        unix = plat.startswith(('linux-', 'osx-')),
        win = plat.startswith('win-'),
        win32 = bool(plat == 'win-32'),
        win64 = bool(plat == 'win-64'),
        pl = pl,
        py = py,
        py3k = bool(30 <= py < 40),
        py2k = bool(20 <= py < 30),
        py26 = bool(py == 26),
        py27 = bool(py == 27),
        py33 = bool(py == 33),
        py34 = bool(py == 34),
        py35 = bool(py == 35),
        np = np,
    )
    for machine in cc.non_x86_linux_machines:
        namespace[machine] = bool(plat == 'linux-%s' % machine)

    lines = []
    data = open(os.path.join(recipe, 'meta.yaml')).read()
    for i, line in enumerate(data.splitlines()):
        line = line.rstrip()
        if line.lstrip().startswith('#'):
            continue
        m = sel_pat.match(line)
        if m:
            cond = m.group(3)
            rest = m.group(1)
            try:
                if eval(cond, namespace, {}):
                    lines.append(rest)
            except:
                sys.exit('''\
Error: Invalid selector in meta.yaml line %d:
%s
''' % (i + 1, line))
                sys.exit(1)
            continue
        lines.append(line)
    result = yaml.load('\n'.join(lines) + '\n')
    return result.get('build', {}).get('skip') or False

if __name__ == "__main__":
    recipe = '../recipes/bx-python'
    data =os.path.join(recipe, 'meta.yaml')
    print(should_skip(data, '35'))
    print(should_skip(data, '27'))
