import os
import subprocess as sp
import pytest
from textwrap import dedent
import yaml
import tempfile
import requests
from bioconda_utils import utils
from bioconda_utils import docker_utils
from bioconda_utils import cli


def ensure_missing(package):
    """
    If a package is deleted from the conda-bld directory but conda-index is not
    re-run, it remains in the metadata (.index.json, repodata.json) files and
    appears to conda as if the recipe still exists.  This ensures that the
    package is deleted and is removed from the index. Useful for test cases.
    """
    if os.path.exists(package):
        os.unlink(package)
    assert not os.path.exists(package)
    sp.check_call(['conda', 'index', os.path.dirname(package)])


class Recipes(object):
    def __init__(self, data, from_string=False):
        """
        Handles the creation of a directory of recipes.

        This class, combined with YAML files describing test cases, can be used
        for building test cases of interdependent recipes in an isolated
        directory.

        Recipes are specified in a YAML file. Each top-level key represents
        a recipe, and the recipe will be written in a temp dir named after that
        key. Sub-keys are filenames to create in that directory, and the value
        of each sub-key is a string (likely a multi-line string indicated with
        a "|").

        For example, this YAML file::

            one:
              meta.yaml: |
                package:
                  name: one
                  version: 0.1
              build.sh: |
                  #!/bin/bash
                  # do installation
            two:
              meta.yaml: |
                package:
                  name: two
                  version: 0.1
              build.sh:
                  #!/bin/bash
                  python setup.py install

        will result in these files::

            /tmp/tmpdirname/
              one/
                meta.yaml
                build.sh
              two/
                meta.yaml
                build.sh

        Parameters
        ----------

        data : str
            If `from_string` is False, this is a filename relative to this
            module's file. If `from_string` is True, then use the contents of
            the string directly.

        from_string : bool


        Useful attributes:

        * recipes: a dict mapping recipe names to parsed meta.yaml contents
        * basedir: the tempdir containing all recipes. Many bioconda-utils
                   functions need the "recipes dir"; that's this basedir.
        * recipe_dirs: a dict mapping recipe names to newly-created recipe
                   dirs. These are full paths to subdirs in `basedir`.
        """

        if from_string:
            self.data = data
            self.recipes = yaml.load(data)
        else:
            self.data = os.path.join(os.path.dirname(__file__), data)
            self.recipes = yaml.load(open(self.data))

    def write_recipes(self):
        basedir = tempfile.mkdtemp()
        self.recipe_dirs = {}
        for name, recipe in self.recipes.items():
            rdir = os.path.join(basedir, name)
            os.makedirs(rdir)
            self.recipe_dirs[name] = rdir
            for key, value in recipe.items():
                with open(os.path.join(rdir, key), 'w') as fout:
                    fout.write(value)
        self.basedir = basedir

with open('test_env_matrix.yaml', 'w') as fout:
    fout.write(dedent(
        """\
        CONDA_PY:
          - "2.7"
          - "3.5"
        CONDA_BOOST: "1.60"
        CONDA_R: "3.3.1"
        CONDA_PERL: "5.22.0"
        CONDA_NPY: "110"
        CONDA_NCURSES: "5.9"
        CONDA_GSL: "1.16"
        CONDA_GMP: "5.1"
        """))


def test_get_deps():
    r = Recipes('test_case.yaml')
    r.write_recipes()
    assert list(utils.get_deps(r.recipe_dirs['two']))[0] == 'one'
    r.recipes['two']['meta.yaml']['requirements']['build'] = []
    r.write_recipes()
    assert list(utils.get_deps(r.recipe_dirs['two'])) == []


def _single_build(docker_builder=None):
    """
    Tests the building of a single configured recipe, with or without docker
    """
    r = Recipes('test_case.yaml')
    r.write_recipes()
    env_matrix = list(utils.EnvMatrix('test_env_matrix.yaml'))[0]
    conda_bld = docker_utils.get_host_conda_bld()
    built_package = os.path.join(conda_bld, 'linux-64', 'one-0.1-0.tar.bz2')
    ensure_missing(built_package)
    utils.build(
        recipe=r.recipe_dirs['one'],
        recipe_folder='.',
        docker_builder=docker_builder,
        env=env_matrix)
    assert os.path.exists(built_package)
    ensure_missing(built_package)


def test_single_build():
    _single_build(docker_builder=None)


def test_single_build_docker_with_post_test():
    docker_builder = docker_utils.RecipeBuilder(verbose=True)
    r = Recipes('test_case.yaml')
    r.write_recipes()
    env_matrix = list(utils.EnvMatrix('test_env_matrix.yaml'))[0]
    conda_bld = docker_utils.get_host_conda_bld()
    built_package = os.path.join(conda_bld, 'linux-64', 'one-0.1-0.tar.bz2')
    ensure_missing(built_package)
    utils.build(
        recipe=r.recipe_dirs['one'],
        recipe_folder='.',
        docker_builder=docker_builder,
        env=env_matrix)
    assert os.path.exists(built_package)

    docker_builder.test_recipe('one')


def test_single_build_docker():
    docker_builder = docker_utils.RecipeBuilder(verbose=True)
    _single_build(docker_builder=docker_builder)


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
    docker_builder.build_recipe(recipe_dir, build_args='')
    assert os.path.exists(built_package)
    os.unlink(built_package)
    assert not os.path.exists(built_package)


def test_docker_build_image_fails():
    template = dedent(
        """
        FROM {self.image}
        RUN nonexistent command
        """)
    with pytest.raises(docker_utils.DockerBuildError):
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
        'CONDA_PY': ['2.7', '3.5'],
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
            ('CONDA_PY', '2.7'),
        ],
        [
            ('CONDA_BOOST', '1.60'),
            ('CONDA_PY', '3.5'),
        ]
    ]


def test_filter_recipes():
    r = Recipes('test_case.yaml')
    r.write_recipes()
    env_matrix = {
        'CONDA_PY': ['2.7', '3.5'],
        'CONDA_BOOST': '1.60'
    }
    recipes = list(r.recipe_dirs.values())
    assert len(recipes) == 3
    filtered = list(
        utils.filter_recipes(recipes, env_matrix, channels=['bioconda']))
    assert len(filtered) == 3


def test_get_channel_packages():
    with pytest.raises(requests.HTTPError):
        utils.get_channel_packages('bioconda_xyz_nonexistent_channel')
    utils.get_channel_packages('bioconda')
