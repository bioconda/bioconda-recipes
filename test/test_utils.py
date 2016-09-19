import os
import subprocess as sp
import pytest
from textwrap import dedent
import yaml
import tempfile
from bioconda_utils import utils
from bioconda_utils import docker_utils


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
    def __init__(self, filename):
        """
        Handles the creation of a directory of recipes.

        This class, combined with YAML files describing test cases, can be used
        for building test cases of interdependent recipes.

        Recipes are specified in a YAML file.  Each block (delimited by "---")
        represents a recipe and must at least include a meta.yaml key,
        containing the meta.yaml contents in standard YAML format.  Any other
        keys are assumed to be filenames, and their string contents will be
        saved to that recipe.

        For example, this YAML file::

            ---
            meta.yaml:
              package:
                name: one
                version: 0.1
            build.sh: |
                #!/bin/bash
                # do installation
            ---
            meta.yaml:
              package:
                name: two
                version: 0.1
            build.sh:
                #!/bin/bash
                python setup.py install

        will result in these files:

            /tmp/tmpdirname/
              one/
                meta.yaml
                build.sh
              two/
                meta.yaml
                build.sh
        """
        self.filename = os.path.join(os.path.dirname(__file__), filename)
        self.recipes = {}
        for recipe in yaml.load_all(open(self.filename)):
            self.recipes[recipe['meta.yaml']['package']['name']] = recipe

    def write_recipes(self):
        basedir = tempfile.mkdtemp()
        self.recipe_dirs = {}
        for name, recipe in self.recipes.items():
            rdir = os.path.join(basedir, name)
            os.makedirs(rdir)
            self.recipe_dirs[name] = rdir
            with open(os.path.join(rdir, 'meta.yaml'), 'w') as fout:
                fout.write(yaml.dump(recipe['meta.yaml'], default_flow_style=False))
            for key, value in recipe.items():
                if key == 'meta.yaml':
                    continue
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
        config={}, env=env_matrix)
    assert os.path.exists(built_package)
    ensure_missing(built_package)


def test_single_build():
    _single_build(docker_builder=None)


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
        docker_builder = docker_utils.RecipeBuilder(verbose=True, dockerfile_template=template)


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
    assert sorted([sorted(i) for i in e1]) == sorted([sorted(i) for i in e2]) == [
        [
            ('CONDA_BOOST', '1.60'),
            ('CONDA_PY', '2.7'),
        ],
        [
            ('CONDA_BOOST', '1.60'),
            ('CONDA_PY', '3.5'),
        ]
    ]


