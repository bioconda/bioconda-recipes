import os
import subprocess as sp
import pytest
import yaml
import tempfile
import requests
import uuid
import contextlib
from bioconda_utils import utils
from bioconda_utils import pkg_test
from bioconda_utils import docker_utils
from bioconda_utils import cli
from bioconda_utils import build
from bioconda_utils import upload
from helpers import ensure_missing, Recipes, tmp_env_matrix
from conda_build import api
from conda_build.metadata import MetaData

# TODO: need channel order tests. Could probably do this by adding different
# file:// channels with different variants of the same package


# Label that will be used for uploading test packages to anaconda/binstar
TEST_LABEL = 'bioconda-utils-test'

SKIP_DOCKER_TESTS = os.environ.get('TRAVIS_OS_NAME') == 'osx'

if SKIP_DOCKER_TESTS:
    PARAMS = [False]
    IDS = ['system conda']
else:
    PARAMS = [True, False]
    IDS = ['with docker', 'system conda']


@contextlib.contextmanager
def ensure_env_missing(env_name):
    """
    context manager that makes sure a conda env of a particular name does not
    exist, deleting it if needed.
    """
    def _clean():
        p = sp.run(
            ['conda', 'env', 'list'],
            stdout=sp.PIPE, stderr=sp.STDOUT, check=True,
            universal_newlines=True)

        if env_name in p.stdout:
            p = sp.run(
                ['conda', 'env', 'remove', '-y', '-n', env_name],
                stdout=sp.PIPE, stderr=sp.STDOUT, check=True,
                universal_newlines=True)
    _clean()
    yield
    _clean()


# ----------------------------------------------------------------------------
# FIXTURES
#
@pytest.fixture(scope='module')
def recipes_fixture():
    """
    Writes example recipes (based on test_case.yaml), figures out the package
    paths and attaches them to the Recipes instance, and cleans up afterward.
    """
    r = Recipes('test_case.yaml')
    r.write_recipes()
    r.pkgs = {}
    for k, v in r.recipe_dirs.items():
        r.pkgs[k] = utils.built_package_path(v)
    yield r
    for v in r.pkgs.values():
        ensure_missing(v)


@pytest.fixture(scope='module', params=PARAMS, ids=IDS)
def single_build(request, recipes_fixture):
    """
    Builds the "one" recipe.
    """
    env_matrix = list(utils.EnvMatrix(tmp_env_matrix()))[0]
    if request.param:
        docker_builder = docker_utils.RecipeBuilder(use_host_conda_bld=True)
    else:
        docker_builder = None
    build.build(
        recipe=recipes_fixture.recipe_dirs['one'],
        recipe_folder='.',
        docker_builder=docker_builder,
        env=env_matrix,
    )
    built_package = recipes_fixture.pkgs['one']
    yield built_package
    ensure_missing(built_package)



# TODO: need to have a variant of this where TRAVIS_BRANCH_NAME="master" in
# order to properly test for upload.
@pytest.fixture(scope='module', params=PARAMS, ids=IDS)
def multi_build(request, recipes_fixture):
    """
    Builds the "one", "two", and "three" recipes.
    """
    if request.param:
        docker_builder = docker_utils.RecipeBuilder(use_host_conda_bld=True)
    else:
        docker_builder = None
    build.build_recipes(
        recipe_folder=recipes_fixture.basedir,
        docker_builder=docker_builder,
        config={},
    )
    built_packages = recipes_fixture.pkgs
    yield built_packages
    for v in built_packages.values():
        ensure_missing(v)


@pytest.fixture(scope='module')
def single_upload():
    """
    Creates a randomly-named recipe and uploads it using a label so that it
    doesn't affect the main bioconda channel. Tests that depend on this fixture
    get a tuple of name, pakage, recipe dir. Cleans up when it's done.
    """
    name = 'upload-test-' + str(uuid.uuid4()).split('-')[0]
    r = Recipes(
        '''
        {0}:
          meta.yaml: |
            package:
              name: {0}
              version: "0.1"
        '''.format(name), from_string=True)
    r.write_recipes()

    env_matrix = list(utils.EnvMatrix(tmp_env_matrix()))[0]
    build.build(
        recipe=r.recipe_dirs[name],
        recipe_folder='.',
        docker_builder=None,
        mulled_test=False,
        env=env_matrix,
    )

    pkg = utils.built_package_path(r.recipe_dirs[name])

    with utils.temp_env(dict(
        TRAVIS_BRANCH='master',
        TRAVIS_PULL_REQUEST='false')
    ):
        upload.anaconda_upload(pkg, label=TEST_LABEL)

    yield (name, pkg, r.recipe_dirs[name])

    p = sp.run(
        ['anaconda', '-t', os.environ.get('ANACONDA_TOKEN'), 'remove',
         'bioconda/{0}'.format(name), '--force'],
        stdout=sp.PIPE, stderr=sp.STDOUT, check=True,
        universal_newlines=True)

# ----------------------------------------------------------------------------


@pytest.mark.skipif(
    not os.environ.get('ANACONDA_TOKEN'),
    reason='No ANACONDA_TOKEN found'
)
def test_upload(single_upload):
    name, pkg, recipe = single_upload
    env_name = 'bioconda-utils-test-' + str(uuid.uuid4()).split('-')[0]
    with ensure_env_missing(env_name):
        p = sp.run(
            ['conda', 'create', '-n', env_name,
             '-c', 'bioconda/label/{0}'.format(TEST_LABEL), name],
            stdout=sp.PIPE, stderr=sp.STDOUT, check=True,
            universal_newlines=True)


def test_single_build_only(single_build):
    assert os.path.exists(single_build)


def test_single_build_with_post_test(single_build):
    pkg_test.test_package(single_build)


def test_multi_build(multi_build):
    for v in multi_build.values():
        assert os.path.exists(v)


@pytest.mark.skipif(SKIP_DOCKER_TESTS, reason='skipping on osx')
def test_docker_builder_build(recipes_fixture):
    """
    Tests just the build_recipe method of a RecipeBuilder object.
    """
    docker_builder = docker_utils.RecipeBuilder(use_host_conda_bld=True)
    docker_builder.build_recipe(
        recipes_fixture.recipe_dirs['one'], build_args='', env={})
    assert os.path.exists(recipes_fixture.pkgs['one'])


@pytest.mark.skipif(SKIP_DOCKER_TESTS, reason='skipping on osx')
def test_docker_build_fails(recipes_fixture):
    "test for expected failure when a recipe fails to build"
    docker_builder = docker_utils.RecipeBuilder(
        build_script_template="exit 1")
    assert docker_builder.build_script_template == 'exit 1'
    result = build.build_recipes(
        recipes_fixture.basedir,
        config={},
        docker_builder=docker_builder,
        mulled_test=True,
    )
    assert not result


@pytest.mark.skipif(SKIP_DOCKER_TESTS, reason='skipping on osx')
def test_docker_build_image_fails():
    template = (
        """
        FROM {self.image}
        RUN nonexistent command
        """)
    with pytest.raises(sp.CalledProcessError):
        docker_builder = docker_utils.RecipeBuilder(
             dockerfile_template=template)


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


def test_get_deps():
    r = Recipes(
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
    """, from_string=True)
    r.write_recipes()
    assert list(utils.get_deps(r.recipe_dirs['two'])) == ['one']
    assert list(utils.get_deps(r.recipe_dirs['three'], build=True)) == ['one']
    assert list(utils.get_deps(r.recipe_dirs['three'], build=False)) == ['two']


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
    r = Recipes(
        """
        one:
          meta.yaml: |
            package:
              name: one
              version: "0.1"
        """, from_string=True)
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
    """

    """
    r = Recipes(
        """
        one:
          meta.yaml: |
            package:
              name: one
              version: "0.1"
            build:
              skip: true
        """, from_string=True)
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
    r = Recipes(
        """
        one:
          meta.yaml: |
            package:
              name: one
              version: "0.1"
            build:
              skip: true  # [py27]
        """, from_string=True)
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
    r = Recipes(
        """
        one:
          meta.yaml: |
            package:
              name: one
              version: "0.1"
            requirements:
              build:
                - python
              run:
                - python
        """, from_string=True)
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

    r = Recipes(
        """
        one:
          meta.yaml: |
            package:
              name: one
              version: "0.1"
            build:
              skip: True # [py27]
            requirements:
              build:
                - python
              run:
                - python
        """, from_string=True)
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
    r = Recipes(
        """
        one:
          meta.yaml: |
            package:
              name: one
              version: "0.1"
            build:
              number: 0
              string: {{CONDA_EXTRA}}_{{PKG_BUILDNUM}}
        """, from_string=True)
    r.write_recipes()
    recipe = r.recipe_dirs['one']

    from conda_build.render import bldpkg_path

    metadata = MetaData(recipe, api.Config(**dict(CONDA_EXTRA='asdf')))
    print(bldpkg_path(metadata, metadata.config))

    os.environ['CONDA_EXTRA'] = 'asdf'
    pkg = utils.built_package_path(recipe)
    assert os.path.basename(pkg) == 'one-0.1-asdf_0.tar.bz2'


def test_filter_recipes_existing_package():
    "use a known-to-exist package in bioconda"

    # note that we need python as a run requirement in order to get the "pyXY"
    # in the build string that matches the existing bioconda built package.
    r = Recipes(
        """
        one:
          meta.yaml: |
            package:
              name: gffutils
              version: "0.8.7.1"
            requirements:
              run:
                - python
        """, from_string=True)
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


def test_filter_recipes_custom_buildstring():
    "use a known-to-exist package in bioconda"

    # note that we need python as a run requirement in order to get the "pyXY"
    # in the build string that matches the existing bioconda built package.
    r = Recipes(
        """
        one:
          meta.yaml: |
            package:
              name: pindel
              version: "0.2.5b8"
            build:
              number: 2
              skip: True  # [osx]
              string: "htslib{{CONDA_HTSLIB}}_{{PKG_BUILDNUM}}"
            requirements:
              run:
                - python
        """, from_string=True)
    r.write_recipes()
    recipes = list(r.recipe_dirs.values())
    env_matrix = {
        'CONDA_HTSLIB': "1.4",
    }
    filtered = list(
        utils.filter_recipes(recipes, env_matrix, channels=['bioconda']))
    assert len(filtered) == 0


def test_filter_recipes_force_existing_package():
    "same as above but force the recipe"

    # same as above, but this time force the recipe
    # TODO: refactor as py.test fixture
    r = Recipes(
        """
        one:
          meta.yaml: |
            package:
              name: gffutils
              version: "0.8.7.1"
            requirements:
              run:
                - python
        """, from_string=True)
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
    r = Recipes(
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
        """, from_string=True)
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
    r = Recipes(
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
        """, from_string=True)
    r.write_recipes()

    os.environ['CONDA_NCURSES'] = '9.0'
    assert os.path.basename(
        utils.built_package_path(r.recipe_dirs['two'], env=os.environ)
    ) == 'two-0.1-ncurses9.0_0.tar.bz2'

    del os.environ['CONDA_NCURSES']
    assert os.path.basename(
        utils.built_package_path(
            r.recipe_dirs['two'], env=dict(CONDA_NCURSES='9.0'))
    ) == 'two-0.1-ncurses9.0_0.tar.bz2'


def test_pkgname_with_numpy_x_x():
    r = Recipes(
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

        """, from_string=True)
    r.write_recipes()

    os.environ['CONDA_NPY'] = '1.9'
    assert os.path.basename(
        utils.built_package_path(r.recipe_dirs['one'], env=os.environ)
    ) == 'one-0.1-np19py35_0.tar.bz2'


def test_string_or_float_to_integer_python():
    f = utils._string_or_float_to_integer_python
    assert f(27) == f('27') == f(2.7) == f('2.7') == 27


def test_skip_dependencies():
    r = Recipes(
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
                - nonexistent
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
    """, from_string=True)
    r.write_recipes()
    pkgs = {}
    for k, v in r.recipe_dirs.items():
        pkgs[k] = utils.built_package_path(v)

    for p in pkgs.values():
        ensure_missing(p)

    build.build_recipes(
        r.basedir,
        config={},
        packages="*",
        testonly=False,
        force=False,
        mulled_test=False,
    )
    assert os.path.exists(pkgs['one'])
    assert not os.path.exists(pkgs['two'])
    assert not os.path.exists(pkgs['three'])

    # clean up
    for p in pkgs.values():
        ensure_missing(p)


class TestSubdags(object):
    def _build(self, recipes_fixture):
        build.build_recipes(recipes_fixture.basedir, config={}, mulled_test=False)

    def test_subdags_out_of_range(self, recipes_fixture):
        with pytest.raises(ValueError):
            with utils.temp_env({'SUBDAGS': '1', 'SUBDAG': '5'}):
                self._build(recipes_fixture)

    def test_subdags_more_than_recipes(self, caplog, recipes_fixture):
        with utils.temp_env({'SUBDAGS': '5', 'SUBDAG': '4'}):
            self._build(recipes_fixture)
        assert 'Nothing to be done' in caplog.records[-1].getMessage()


def test_zero_packages():
    """
    Regression test; make sure filter_recipes exits cleanly if no recipes were
    provided.
    """
    assert list(utils.filter_recipes([], {'CONDA_PY': [27, 35]})) == []
