import os
import sys
import subprocess as sp
import pytest
import yaml
import tempfile
import requests
import uuid
import contextlib
import tarfile
import logging
import shutil
from textwrap import dedent

from bioconda_utils import utils
from bioconda_utils import pkg_test
from bioconda_utils import docker_utils
from bioconda_utils import build
from bioconda_utils import upload
from helpers import ensure_missing, Recipes

# TODO: need channel order tests. Could probably do this by adding different
# file:// channels with different variants of the same package


# Label that will be used for uploading test packages to anaconda/binstar
TEST_LABEL = 'bioconda-utils-test'

# PARAMS and ID are used with pytest.fixture. The end result is that, on Linux,
# any tests that depend on a fixture that uses PARAMS will run twice (once with
# docker, once without). On OSX, only the non-docker runs.

SKIP_DOCKER_TESTS = sys.platform.startswith('darwin')

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
        r.pkgs[k] = utils.built_package_paths(v)
    yield r
    for pkgs in r.pkgs.values():
        for pkg in pkgs:
            ensure_missing(pkg)


@pytest.fixture(scope='module', params=PARAMS, ids=IDS)
def single_build(request, recipes_fixture):
    """
    Builds the "one" recipe.
    """
    if request.param:
        docker_builder = docker_utils.RecipeBuilder(use_host_conda_bld=True)
        mulled_test = True
    else:
        docker_builder = None
        mulled_test = False
    build.build(
        recipe=recipes_fixture.recipe_dirs['one'],
        recipe_folder='.',
        pkg_paths=recipes_fixture.pkgs['one'],
        docker_builder=docker_builder,
        mulled_test=mulled_test,
    )
    yield recipes_fixture.pkgs['one']
    for pkg in recipes_fixture.pkgs['one']:
        ensure_missing(pkg)


# TODO: need to have a variant of this where TRAVIS_BRANCH_NAME="master" in
# order to properly test for upload.
@pytest.fixture(scope='module', params=PARAMS, ids=IDS)
def multi_build(request, recipes_fixture):
    """
    Builds the "one", "two", and "three" recipes.
    """
    if request.param:
        docker_builder = docker_utils.RecipeBuilder(use_host_conda_bld=True)
        mulled_test = True
    else:
        docker_builder = None
        mulled_test = False
    build.build_recipes(
        recipe_folder=recipes_fixture.basedir,
        docker_builder=docker_builder,
        config={},
        mulled_test=mulled_test,
    )
    built_packages = recipes_fixture.pkgs
    yield built_packages
    for pkgs in built_packages.values():
        for pkg in pkgs:
            ensure_missing(pkg)


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
    r.pkgs = {}
    r.pkgs[name] = utils.built_package_paths(r.recipe_dirs[name])

    build.build(
        recipe=r.recipe_dirs[name],
        recipe_folder='.',
        pkg_paths=r.pkgs[name],
        docker_builder=None,
        mulled_test=False
    )
    pkg = r.pkgs[name][0]

    upload.anaconda_upload(pkg, label=TEST_LABEL)

    yield (name, pkg, r.recipe_dirs[name])

    sp.run(
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
        sp.run(
            ['conda', 'create', '-n', env_name,
             '-c', 'bioconda/label/{0}'.format(TEST_LABEL), name],
            stdout=sp.PIPE, stderr=sp.STDOUT, check=True,
            universal_newlines=True)


def test_single_build_only(single_build):
    for pkg in single_build:
        assert os.path.exists(pkg)


@pytest.mark.skipif(SKIP_DOCKER_TESTS, reason='skipping on osx')
def test_single_build_with_post_test(single_build):
    for pkg in single_build:
        pkg_test.test_package(pkg)


@pytest.mark.long_running
def test_multi_build(multi_build):
    for v in multi_build.values():
        for pkg in v:
            assert os.path.exists(pkg)


@pytest.mark.skipif(SKIP_DOCKER_TESTS, reason='skipping on osx')
def test_docker_builder_build(recipes_fixture):
    """
    Tests just the build_recipe method of a RecipeBuilder object.
    """
    docker_builder = docker_utils.RecipeBuilder(use_host_conda_bld=True)
    pkgs = recipes_fixture.pkgs['one']
    docker_builder.build_recipe(
        recipes_fixture.recipe_dirs['one'], build_args='', env={})
    for pkg in pkgs:
        assert os.path.exists(pkg)


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
        FROM bioconda/bioconda-utils-build-env
        RUN nonexistent command
        """)
    with pytest.raises(sp.CalledProcessError):
        docker_utils.RecipeBuilder(dockerfile_template=template)


def test_conda_purge_cleans_up():
    def tmp_dir_exists(d):
        contents = os.listdir(d)
        print("conda-bld/:", *contents)
        for i in contents:
            if i.startswith('deleteme_'):
                return True
        return False

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


def test_conda_as_dep():
    r = Recipes(
        """
        one:
          meta.yaml: |
            package:
              name: one
              version: 0.1
            requirements:
              run:
                - conda
        """, from_string=True)
    r.write_recipes()
    build_result = build.build_recipes(
        r.basedir,
        config={},
        packages="*",
        testonly=False,
        force=False,
        mulled_test=True,
    )
    assert build_result

# TODO replace the filter tests with tests for utils.get_package_paths()
# def test_filter_recipes_no_skipping():
#     """
#     No recipes have skip so make sure none are filtered out.
#     """
#     r = Recipes(
#         """
#         one:
#           meta.yaml: |
#             package:
#               name: one
#               version: "0.1"
#         """, from_string=True)
#     r.write_recipes()
#     recipes = list(r.recipe_dirs.values())
#     assert len(recipes) == 1
#     filtered = list(
#         utils.filter_recipes(recipes, channels=['bioconda']))
#     assert len(filtered) == 1
#
#
# def test_filter_recipes_skip_is_true():
#     r = Recipes(
#         """
#         one:
#           meta.yaml: |
#             package:
#               name: one
#               version: "0.1"
#             build:
#               skip: true
#         """, from_string=True)
#     r.write_recipes()
#     recipes = list(r.recipe_dirs.values())
#     filtered = list(
#         utils.filter_recipes(recipes))
#     print(filtered)
#     assert len(filtered) == 0
#
#
# def test_filter_recipes_skip_is_true_with_CI_env_var():
#     """
#     utils.filter_recipes has a conditional that checks to see if there's
#     a CI=true env var which in some cases only causes failure when running on
#     CI. So temporarily fake it here so that local tests catch errors.
#     """
#     with utils.temp_env(dict(CI="true")):
#         r = Recipes(
#             """
#             one:
#               meta.yaml: |
#                 package:
#                   name: one
#                   version: "0.1"
#                 build:
#                   skip: true
#             """, from_string=True)
#         r.write_recipes()
#         recipes = list(r.recipe_dirs.values())
#         filtered = list(
#             utils.filter_recipes(recipes))
#         print(filtered)
#         assert len(filtered) == 0
#
#
# def test_filter_recipes_skip_not_py27():
#     """
#     When all but one Python version is skipped, filtering should do that.
#     """
#
#     r = Recipes(
#         """
#         one:
#           meta.yaml: |
#             package:
#               name: one
#               version: "0.1"
#             build:
#               skip: True # [not py27]
#             requirements:
#               build:
#                 - python
#               run:
#                 - python
#         """, from_string=True)
#     r.write_recipes()
#     recipes = list(r.recipe_dirs.values())
#     filtered = list(
#         utils.filter_recipes(recipes, channels=['bioconda']))
#
#     # one recipe, one target
#     assert len(filtered) == 1
#     assert len(filtered[0][1]) == 1
#
#
# def test_filter_recipes_existing_package():
#     "use a known-to-exist package in bioconda"
#
#     # note that we need python as a run requirement in order to get the "pyXY"
#     # in the build string that matches the existing bioconda built package.
#     r = Recipes(
#         """
#         one:
#           meta.yaml: |
#             package:
#               name: gffutils
#               version: "0.8.7.1"
#             requirements:
#               build:
#                 - python
#               run:
#                 - python
#         """, from_string=True)
#     r.write_recipes()
#     recipes = list(r.recipe_dirs.values())
#     filtered = list(
#         utils.filter_recipes(recipes, channels=['bioconda']))
#     assert len(filtered) == 0
#
#
# def test_filter_recipes_force_existing_package():
#     "same as above but force the recipe"
#
#     # same as above, but this time force the recipe
#     # TODO: refactor as py.test fixture
#     r = Recipes(
#         """
#         one:
#           meta.yaml: |
#             package:
#               name: gffutils
#               version: "0.8.7.1"
#             requirements:
#               run:
#                 - python
#         """, from_string=True)
#     r.write_recipes()
#     recipes = list(r.recipe_dirs.values())
#     filtered = list(
#         utils.filter_recipes(
#             recipes, channels=['bioconda'], force=True))
#     assert len(filtered) == 1
#
#
# def test_zero_packages():
#     """
#     Regression test; make sure filter_recipes exits cleanly if no recipes were
#     provided.
#     """
#     assert list(utils.filter_recipes([])) == []


def test_get_channel_packages():
    with pytest.raises(requests.HTTPError):
        utils.get_channel_packages('bioconda_xyz_nonexistent_channel')
    utils.get_channel_packages('bioconda')


def test_built_package_paths():
    r = Recipes(
        """
        one:
          meta.yaml: |
            package:
              name: one
              version: "0.1"
            requirements:
              build:
                - python 3.6
              run:
                - python 3.6

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

    assert os.path.basename(
        utils.built_package_paths(r.recipe_dirs['one'])[0]
    ) == 'one-0.1-py36_0.tar.bz2'


def test_string_or_float_to_integer_python():
    f = utils._string_or_float_to_integer_python
    assert f(27) == f('27') == f(2.7) == f('2.7') == 27


def test_rendering_sandboxing():
    r = Recipes(
        """
        one:
          meta.yaml: |
            package:
              name: one
              version: 0.1
            extra:
              var: {{ GITHUB_TOKEN }}
    """, from_string=True)

    r.write_recipes()
    env = {
        # First one is allowed, others are not
        'CONDA_ARBITRARY_VAR': 'conda-val-here',
        'TRAVIS_ARBITRARY_VAR': 'travis-val-here',
        'GITHUB_TOKEN': 'asdf',
        'BUILDKITE_TOKEN': 'asdf',
    }

    # If GITHUB_TOKEN is already set in the bash environment, then we get
    # a message on stdout+stderr (this is the case on travis-ci).
    #
    # However if GITHUB_TOKEN is not already set in the bash env (e.g., when
    # testing locally), then we get a SystemError.
    #
    # In both cases we're passing in the `env` dict, which does contain
    # GITHUB_TOKEN.

    if 'GITHUB_TOKEN' in os.environ:
        with pytest.raises(sp.CalledProcessError) as excinfo:
            pkg_paths = utils.built_package_paths(r.recipe_dirs['one'])
            build.build(
                recipe=r.recipe_dirs['one'],
                recipe_folder='.',
                pkg_paths=pkg_paths,
                mulled_test=False,
                _raise_error=True,
            )
        assert ("'GITHUB_TOKEN' is undefined" in str(excinfo.value.stdout))
    else:
        # recipe for "one" should fail because GITHUB_TOKEN is not a jinja var.
        with pytest.raises(SystemExit) as excinfo:
            pkg_paths = utils.built_package_paths(r.recipe_dirs['one'])
            build.build(
                recipe=r.recipe_dirs['one'],
                recipe_folder='.',
                pkg_paths=pkg_paths,
                mulled_test=False,
            )
        assert "'GITHUB_TOKEN' is undefined" in str(excinfo.value)

    r = Recipes(
        """
        two:
          meta.yaml: |
            package:
              name: two
              version: 0.1
            extra:
              var2: {{ CONDA_ARBITRARY_VAR }}

    """, from_string=True)
    r.write_recipes()

    with utils.temp_env(env):
        pkg_paths = utils.built_package_paths(r.recipe_dirs['two'])
        for pkg in pkg_paths:
            ensure_missing(pkg)

        build.build(
            recipe=r.recipe_dirs['two'],
            recipe_folder='.',
            pkg_paths=pkg_paths,
            mulled_test=False,
        )

        for pkg in pkg_paths:
            t = tarfile.open(pkg)
            tmp = tempfile.mkdtemp()
            target = 'info/recipe/meta.yaml'
            t.extract(target, path=tmp)
            contents = yaml.load(open(os.path.join(tmp, target)).read())
            assert contents['extra']['var2'] == 'conda-val-here', contents


def test_sandboxed():
    env = {
        'CONDA_ARBITRARY_VAR': 'conda-val-here',
        'TRAVIS_ARBITRARY_VAR': 'travis-val-here',
        'GITHUB_TOKEN': 'asdf',
        'BUILDKITE_TOKEN': 'asdf',
    }
    with utils.sandboxed_env(env):
        print(os.environ)
        assert os.environ['CONDA_ARBITRARY_VAR'] == 'conda-val-here'
        assert 'TRAVIS_ARBITRARY_VAR' not in os.environ
        assert 'GITHUB_TOKEN' not in os.environ
        assert 'BUILDKITE_TOKEN' not in os.environ


def test_env_sandboxing():
    r = Recipes(
        """
        one:
          meta.yaml: |
            package:
              name: one
              version: 0.1
          build.sh: |
            #!/bin/bash
            if [[ -z $GITHUB_TOKEN ]]
            then
                exit 0
            else
                echo "\$GITHUB_TOKEN has leaked into the build environment!"
                exit 1
            fi
    """, from_string=True)
    r.write_recipes()
    pkg_paths = utils.built_package_paths(r.recipe_dirs['one'])

    with utils.temp_env({'GITHUB_TOKEN': 'token_here'}):
        build.build(
            recipe=r.recipe_dirs['one'],
            recipe_folder='.',
            pkg_paths=pkg_paths,
            mulled_test=False
        )

    for pkg in pkg_paths:
        assert os.path.exists(pkg)
        ensure_missing(pkg)


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
        pkgs[k] = utils.built_package_paths(v)

    for _pkgs in pkgs.values():
        for pkg in _pkgs:
            ensure_missing(pkg)

    build.build_recipes(
        r.basedir,
        config={},
        packages="*",
        testonly=False,
        force=False,
        mulled_test=False,
    )
    for pkg in pkgs['one']:
        assert os.path.exists(pkg)
    for pkg in pkgs['two']:
        assert not os.path.exists(pkg)
    for pkg in pkgs['three']:
        assert not os.path.exists(pkg)

    # clean up
    for _pkgs in pkgs.values():
        for pkg in _pkgs:
            ensure_missing(pkg)


class TestSubdags(object):
    def _build(self, recipes_fixture):
        build.build_recipes(recipes_fixture.basedir, config={}, mulled_test=False)

    def test_subdags_out_of_range(self, recipes_fixture):
        with pytest.raises(ValueError):
            with utils.temp_env({'SUBDAGS': '1', 'SUBDAG': '5'}):
                self._build(recipes_fixture)

    def test_subdags_more_than_recipes(self, caplog, recipes_fixture):
        with caplog.at_level(logging.INFO):
            with utils.temp_env({'SUBDAGS': '5', 'SUBDAG': '4'}):
                    self._build(recipes_fixture)
            assert 'Nothing to be done' in caplog.records[-1].getMessage()


@pytest.mark.skipif(SKIP_DOCKER_TESTS, reason='skipping on osx')
def test_build_empty_extra_container():
    r = Recipes(
        """
        one:
          meta.yaml: |
            package:
              name: one
              version: 0.1
            extra:
              container:
                # empty
        """, from_string=True)
    r.write_recipes()
    pkgs = utils.built_package_paths(r.recipe_dirs['one'])

    build_result = build.build(
        recipe=r.recipe_dirs['one'],
        recipe_folder='.',
        pkg_paths=pkgs,
        mulled_test=True,
    )
    assert build_result.success
    for pkg in pkgs:
        assert os.path.exists(pkg)
        ensure_missing(pkg)


@pytest.mark.skipif(SKIP_DOCKER_TESTS, reason='skipping on osx')
@pytest.mark.long_running
def test_build_container_default_gcc(tmpdir):
    r = Recipes(
        """
        one:
          meta.yaml: |
            package:
              name: one
              version: 0.1
            test:
              commands:
                - gcc --version
                - 'gcc --version | grep "gcc (GCC) 4.8.2 20140120 (Red Hat 4.8.2-15)"'
        """, from_string=True)
    r.write_recipes()

    # Tests with the repository's Dockerfile instead of already uploaded images.
    # Copy repository to image build directory so everything is in docker context.
    image_build_dir = os.path.join(tmpdir, "repo")
    src_repo_dir = os.path.join(os.path.dirname(__file__), "..")
    shutil.copytree(src_repo_dir, image_build_dir)
    # Dockerfile will be recreated by RecipeBuilder => extract template and delete file
    dockerfile = os.path.join(image_build_dir, "Dockerfile")
    with open(dockerfile) as f:
        dockerfile_template = f.read().replace("{", "{{").replace("}", "}}")
    os.remove(dockerfile)

    docker_builder = docker_utils.RecipeBuilder(
        dockerfile_template=dockerfile_template,
        use_host_conda_bld=True,
        image_build_dir=image_build_dir,
    )

    pkg_paths = utils.built_package_paths(r.recipe_dirs['one'])
    build_result = build.build(
        recipe=r.recipe_dirs['one'],
        recipe_folder='.',
        pkg_paths=pkg_paths,
        docker_builder=docker_builder,
        mulled_test=False,
    )
    assert build_result.success


def test_conda_forge_pins(caplog):
    caplog.set_level(logging.DEBUG)
    r = Recipes(
        """
        one:
          meta.yaml: |
            package:
              name: one
              version: 0.1
            requirements:
              run:
                - zlib {{ zlib }}
        """, from_string=True)
    r.write_recipes()
    build_result = build.build_recipes(
        r.basedir,
        config={},
        packages="*",
        testonly=False,
        force=False,
        mulled_test=False,
    )
    assert build_result

    for k, v in r.recipe_dirs.items():
        for i in utils.built_package_paths(v):
            assert os.path.exists(i)
            ensure_missing(i)


def test_bioconda_pins(caplog):
    """
    htslib currently only provided by bioconda pinnings
    """
    caplog.set_level(logging.DEBUG)
    r = Recipes(
        """
        one:
          meta.yaml: |
            package:
              name: one
              version: 0.1
            requirements:
              run:
                - htslib
        """, from_string=True)
    r.write_recipes()
    build_result = build.build_recipes(
        r.basedir,
        config={},
        packages="*",
        testonly=False,
        force=False,
        mulled_test=False,
    )
    assert build_result

    for k, v in r.recipe_dirs.items():
        for i in utils.built_package_paths(v):
            assert os.path.exists(i)
            ensure_missing(i)


def test_load_meta_skipping():
    """
    Ensure that a skipped recipe returns no metadata
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
    recipe = r.recipe_dirs['one']
    assert utils.load_all_meta(recipe) == []


def test_variants():
    """
    Multiple variants should return multiple metadata
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
                - mypkg {{ mypkg }}
        """, from_string=True)
    r.write_recipes()
    recipe = r.recipe_dirs['one']

    # Write a temporary conda_build_config.yaml that we'll point the config
    # object to:
    tmp = tempfile.NamedTemporaryFile(delete=False).name
    with open(tmp, 'w') as fout:
        fout.write(
            dedent(
                """
                mypkg:
                  - 1.0
                  - 2.0
                """))
    config = utils.load_conda_build_config()
    config.exclusive_config_file = tmp

    assert len(utils.load_all_meta(recipe, config)) == 2


def test_cb3_outputs():
    r = Recipes(
        """
        one:
          meta.yaml: |
            package:
              name: one
              version: "0.1"

            outputs:
              - name: libone
              - name: py-one
                requirements:
                  - {{ pin_subpackage('libone', exact=True) }}
                  - python  {{ python }}

        """, from_string=True)
    r.write_recipes()
    r.recipe_dirs['one']

    build_result = build.build_recipes(
        r.basedir,
        config={},
        packages="*",
        testonly=False,
        force=False,
        mulled_test=False,
    )
    assert build_result

    for k, v in r.recipe_dirs.items():
        for i in utils.built_package_paths(v):
            assert os.path.exists(i)
            ensure_missing(i)


def test_compiler():
    r = Recipes(
        """
        one:
          meta.yaml: |
            package:
              name: one
              version: 0.1
            requirements:
              build:
                - {{ compiler('c') }}
              host:
                - python
              run:
                - python
        """, from_string=True)
    r.write_recipes()
    build_result = build.build_recipes(
        r.basedir,
        config={},
        packages="*",
        testonly=False,
        force=False,
        mulled_test=False,
    )
    assert build_result

    for k, v in r.recipe_dirs.items():
        for i in utils.built_package_paths(v):
            assert os.path.exists(i)
            ensure_missing(i)
