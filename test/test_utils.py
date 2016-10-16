import os
import subprocess as sp
import pytest
from textwrap import dedent
import yaml
import tempfile
import requests
from bioconda_utils import utils
from bioconda_utils import pkg_test
from bioconda_utils import docker_utils
from bioconda_utils import cli
from bioconda_utils import build
from helpers import ensure_missing, Recipes, tmp_env_matrix
from conda_build import api
from conda_build.metadata import MetaData


def test_get_deps():
    r = Recipes(dedent(
        """
        one:
          meta.yaml: |
            package:
              name: one
              version: 0.1
        two:
          meta.yaml: |
            package:
              name: two
              version: 0.1
            requirements:
              build:
                - one
        three:
          meta.yaml: |
            package:
              name: three
              version: 0.1
            requirements:
              build:
                - one
              run:
                - two
    """), from_string=True)
    r.write_recipes()
    assert list(utils.get_deps(r.recipe_dirs['two'])) == ['one']
    assert list(utils.get_deps(r.recipe_dirs['three'], build=True)) == ['one']
    assert list(utils.get_deps(r.recipe_dirs['three'], build=False)) == ['two']


def _single_build(docker_builder=None):
    """
    Tests the building of a single configured recipe, with or without docker
    """
    r = Recipes('test_case.yaml')
    r.write_recipes()
    env_matrix = list(utils.EnvMatrix(tmp_env_matrix()))[0]
    conda_bld = docker_utils.get_host_conda_bld()
    built_package = os.path.join(conda_bld, 'linux-64', 'one-0.1-0.tar.bz2')
    ensure_missing(built_package)
    build.build(
        recipe=r.recipe_dirs['one'],
        recipe_folder='.',
        docker_builder=docker_builder,
        env=env_matrix,
    )
    assert os.path.exists(built_package)
    return built_package


def test_single_build1():
    built_package = _single_build(docker_builder=None)


def test_single_build_docker_with_post_test():
    docker_builder = docker_utils.RecipeBuilder(verbose=True)
    r = Recipes('test_case.yaml')
    r.write_recipes()
    env_matrix = list(utils.EnvMatrix(tmp_env_matrix()))[0]
    conda_bld = docker_utils.get_host_conda_bld()
    built_package = os.path.join(conda_bld, 'linux-64', 'one-0.1-0.tar.bz2')
    ensure_missing(built_package)
    build.build(
        recipe=r.recipe_dirs['one'],
        recipe_folder='.',
        docker_builder=docker_builder,
        env=env_matrix)
    assert os.path.exists(built_package)
    pkg_test.test_package(built_package)
    ensure_missing(built_package)

def test_single_build_docker():
    docker_builder = docker_utils.RecipeBuilder(verbose=True)
    built_package = _single_build(docker_builder=docker_builder)
    ensure_missing(built_package)


def test_docker_builder_build():
    """
    Tests just the build_recipe method of a RecipeBuilder object.

    Makes sure the built recipe shows up on the host machine.
    """
    conda_bld = docker_utils.get_host_conda_bld()
    built_package = os.path.join(conda_bld, 'linux-64', 'one-0.1-0.tar.bz2')
    ensure_missing(built_package)
    docker_builder = docker_utils.RecipeBuilder(verbose=True)
    r = Recipes('test_case.yaml')
    r.write_recipes()
    recipe_dir = r.recipe_dirs['one']
    docker_builder.build_recipe(recipe_dir, build_args='', env={})
    assert os.path.exists(built_package)
    os.unlink(built_package)
    assert not os.path.exists(built_package)


def test_docker_build_image_fails():
    template = dedent(
        """
        FROM {self.image}
        RUN nonexistent command
        """)
    with pytest.raises(sp.CalledProcessError):
        docker_builder = docker_utils.RecipeBuilder(
            verbose=True, dockerfile_template=template)


def test_conda_purge_cleans_up():
    def tmp_dir_exists(d):
        contents = os.listdir(d)
        for i in contents:
            if i.startswith('tmp') and '_' in i:
                return True

    bld = docker_utils.get_host_conda_bld(purge=False)
    assert tmp_dir_exists(bld)
    bld = docker_utils.get_host_conda_bld(purge=True)
    assert not tmp_dir_exists(bld)


def test_local_channel():
    r = Recipes('test_case.yaml')
    r.write_recipes()
    with pytest.raises(SystemExit) as e:
        cli.build(r.basedir,
                  config={},
                  packages="*",
                  testonly=False,
                  force=False,
                  docker=True,
                  loglevel="debug",
                  )
        assert e.code == 0
    conda_bld = docker_utils.get_host_conda_bld()
    print(os.listdir(os.path.join(conda_bld, 'linux-64')))


def test_env_matrix():
    contents = {
        'CONDA_PY': [27, 35],
        'CONDA_BOOST': '1.60'
    }

    with open(tempfile.NamedTemporaryFile().name, 'w') as fout:
        fout.write(yaml.dump(contents, default_flow_style=False))

    e1 = utils.EnvMatrix(contents)
    e2 = utils.EnvMatrix(fout.name)
    assert e1.env == e2.env
    assert sorted(
        [sorted(i) for i in e1]) == sorted([sorted(i) for i in e2]) == [
        [
            ('CONDA_BOOST', '1.60'),
            ('CONDA_PY', 27),
        ],
        [
            ('CONDA_BOOST', '1.60'),
            ('CONDA_PY', 35),
        ]
    ]


def test_filter_recipes_no_skipping():
    """
    No recipes have skip so make sure none are filtered out.
    """
    r = Recipes(dedent(
        """
        one:
          meta.yaml: |
            package:
              name: one
              version: "0.1"
        """), from_string=True)
    r.write_recipes()
    env_matrix = {
        'CONDA_PY': [27, 35],
        'CONDA_BOOST': '1.60'
    }
    recipes = list(r.recipe_dirs.values())
    assert len(recipes) == 1
    filtered = list(
        utils.filter_recipes(recipes, env_matrix, channels=['bioconda']))
    assert len(filtered) == 1


def test_filter_recipes_skip_is_true():
    r = Recipes(dedent(
        """
        one:
          meta.yaml: |
            package:
              name: one
              version: "0.1"
            build:
              skip: true
        """), from_string=True)
    r.write_recipes()
    env_matrix = {}
    recipes = list(r.recipe_dirs.values())
    filtered = list(
        utils.filter_recipes(recipes, env_matrix))
    assert len(filtered) == 0


def test_filter_recipes_skip_py27():
    """
    When we add build/skip = True # [py27] to recipe, it should not be
    filtered out. This is because python version is not encoded in the output
    package name, and so one-0.1-0.tar.bz2 will still be created for py35.
    """
    r = Recipes(dedent(
        """
        one:
          meta.yaml: |
            package:
              name: one
              version: "0.1"
            build:
              skip: true  # [py27]
        """), from_string=True)
    r.write_recipes()
    env_matrix = {
        'CONDA_PY': [27, 35],
        'CONDA_BOOST': '1.60'
    }
    recipes = list(r.recipe_dirs.values())
    filtered = list(
        utils.filter_recipes(recipes, env_matrix, channels=['bioconda']))
    assert len(filtered) == 1


def test_filter_recipes_skip_py27_in_build_string():
    """
    When CONDA_PY is in the build string, py27 should be skipped
    """
    r = Recipes(dedent(
        """
        one:
          meta.yaml: |
            package:
              name: one
              version: "0.1"
            build:
              string: {{CONDA_PY}}_{{PKG_BUILDNUM}}
        """), from_string=True)
    r.write_recipes()
    env_matrix = {
        'CONDA_PY': [27, 35],
    }
    recipes = list(r.recipe_dirs.values())
    filtered = list(
        utils.filter_recipes(recipes, env_matrix, channels=['bioconda']))

    # one recipe, two targets
    assert len(filtered) == 1
    assert len(filtered[0][1]) == 2

    r = Recipes(dedent(
        """
        one:
          meta.yaml: |
            package:
              name: one
              version: "0.1"
            build:
              string: {{CONDA_PY}}_{{PKG_BUILDNUM}}
              skip: True # [py27]
        """), from_string=True)
    r.write_recipes()
    env_matrix = {
        'CONDA_PY': [27, 35],
    }
    recipes = list(r.recipe_dirs.values())
    filtered = list(
        utils.filter_recipes(recipes, env_matrix, channels=['bioconda']))

    # one recipe, one target
    assert len(filtered) == 1
    assert len(filtered[0][1]) == 1


def test_filter_recipes_extra_in_build_string():
    """
    If CONDA_EXTRA is in os.environ, the pkg name should still be identifiable.

    This helps test env vars that don't have other defaults like CONDA_PY does
    (e.g., CONDA_BOOST in bioconda)
    """
    r = Recipes(dedent(
        """
        one:
          meta.yaml: |
            package:
              name: one
              version: "0.1"
            build:
              number: 0
              string: {{CONDA_EXTRA}}_{{PKG_BUILDNUM}}
        """), from_string=True)
    r.write_recipes()
    recipe = r.recipe_dirs['one']

    from conda_build.render import bldpkg_path

    metadata = MetaData(recipe, api.Config(**dict(CONDA_EXTRA='asdf')))
    print(bldpkg_path(metadata, metadata.config))

    os.environ['CONDA_EXTRA'] = 'asdf'
    pkg = utils.built_package_path(recipe)
    assert os.path.basename(pkg) == 'one-0.1-asdf_0.tar.bz2'

def test_filter_recipes_existing_package():
    # use a known-to-exist package in bioconda
    #
    # note that we need python as a run requirement in order to get the "pyXY"
    # in the build string that matches the existing bioconda built package.
    r = Recipes(dedent(
        """
        one:
          meta.yaml: |
            package:
              name: gffutils
              version: "0.8.7.1"
            requirements:
              run:
                - python
        """), from_string=True)
    r.write_recipes()
    recipes = list(r.recipe_dirs.values())
    env_matrix = {
        'CONDA_PY': [27, 35],
    }
    pkgs = utils.get_channel_packages('bioconda')
    pth = utils.built_package_path(recipes[0])
    filtered = list(
        utils.filter_recipes(recipes, env_matrix, channels=['bioconda']))
    assert len(filtered) == 0


def test_filter_recipes_force_existing_package():
    # same as above, but this time force the recipe
    # TODO: refactor as py.test fixture
    r = Recipes(dedent(
        """
        one:
          meta.yaml: |
            package:
              name: gffutils
              version: "0.8.7.1"
            requirements:
              run:
                - python
        """), from_string=True)
    r.write_recipes()
    recipes = list(r.recipe_dirs.values())
    env_matrix = {
        'CONDA_PY': [27, 35],
    }
    pkgs = utils.get_channel_packages('bioconda')
    pth = utils.built_package_path(recipes[0])
    filtered = list(
        utils.filter_recipes(
            recipes, env_matrix, channels=['bioconda'], force=True))
    assert len(filtered) == 1


def test_get_channel_packages():
    with pytest.raises(requests.HTTPError):
        utils.get_channel_packages('bioconda_xyz_nonexistent_channel')
    utils.get_channel_packages('bioconda')


def test_built_package_path():
    r = Recipes(dedent(
        """
        one:
          meta.yaml: |
            package:
              name: one
              version: "0.1"
            requirements:
              run:
                - python

        two:
          meta.yaml: |
            package:
              name: two
              version: "0.1"
            build:
              number: 0
              string: ncurses{{ CONDA_NCURSES }}_{{ PKG_BUILDNUM }}
        """), from_string=True)
    r.write_recipes()

    # assumes we're running on py35
    assert os.path.basename(
        utils.built_package_path(r.recipe_dirs['one'])
    ) == 'one-0.1-py35_0.tar.bz2'

    # resetting with a different CONDA_PY passed as env dict
    assert os.path.basename(
        utils.built_package_path(r.recipe_dirs['one'], env=dict(CONDA_PY=27))
    ) == 'one-0.1-py27_0.tar.bz2'

    # resetting CONDA_PY using os.environ
    existing_env = dict(os.environ)
    try:
        os.environ['CONDA_PY'] = '27'
        assert os.path.basename(
            utils.built_package_path(r.recipe_dirs['one'])
        ) == 'one-0.1-py27_0.tar.bz2'
        os.environ = existing_env
    except:
        os.environ = existing_env
        raise


def test_built_package_path2():
    r = Recipes(dedent(
        """
        one:
          meta.yaml: |
            package:
              name: one
              version: "0.1"
            requirements:
              run:
                - python

        two:
          meta.yaml: |
            package:
              name: two
              version: "0.1"
            build:
              number: 0
              string: ncurses{{ CONDA_NCURSES }}_{{ PKG_BUILDNUM }}
        """), from_string=True)
    r.write_recipes()

    os.environ['CONDA_NCURSES'] = '9.0'
    assert os.path.basename(
        utils.built_package_path(r.recipe_dirs['two'], env=os.environ)
    ) == 'two-0.1-ncurses9.0_0.tar.bz2'

    del os.environ['CONDA_NCURSES']
    assert os.path.basename(
        utils.built_package_path(r.recipe_dirs['two'], env=dict(CONDA_NCURSES='9.0'))
    ) == 'two-0.1-ncurses9.0_0.tar.bz2'



def test_pkgname_with_numpy_x_x():
    r = Recipes(dedent(
        """
        one:
          meta.yaml: |
            package:
              name: one
              version: "0.1"
            requirements:
              run:
                - python
                - numpy x.x
              build:
                - python
                - numpy x.x

        """), from_string=True)
    r.write_recipes()

    os.environ['CONDA_NPY'] = '1.9'
    assert os.path.basename(
        utils.built_package_path(r.recipe_dirs['one'], env=os.environ)
    ) == 'one-0.1-np19py35_0.tar.bz2'


def test_string_or_float_to_integer_python():
    f = utils._string_or_float_to_integer_python
    assert f(27) == f('27') == f(2.7) == f('2.7') == 27
