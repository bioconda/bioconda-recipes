import pandas
import yaml
from helpers import Recipes
from bioconda_utils import lint_functions
from bioconda_utils import linting

def run_lint(
    func_name,
    should_pass,
    should_fail,
    should_pass_df=None,
    should_fail_df=None
):
    """
    Helper function to run a lint function on a set of recipes that should pass
    and that should fail.

    Recall each lint function takes recipe path, parsed meta.yaml, and
    dataframe of channel info.

    Parameters
    ----------
    func_name : str
        Function name to test in `bioconda_utils.lint_functions`

    should_pass, should_fail : str or list
        Recipe definitions that will be provided to `helpers.Recipes`. Each can
        be a single string or a list of strings to test.

    should_pass_df, should_fail_df : pandas.DataFrame
        Optional dataframes to pass to lint function
    """

    if isinstance(should_pass, str):
        should_pass = [should_pass]
    if isinstance(should_fail, str):
        should_fail = [should_fail]

    func = getattr(lint_functions, func_name)

    def _run(contents, expect_pass=True):
        """
        Build the recipe and run the lint function on the rendered recipe
        """
        r = Recipes(contents, from_string=True)
        r.write_recipes()
        assert len(r.recipe_dirs) == 1
        name = list(r.recipe_dirs.keys())[0]
        recipe, meta, df = r.recipe_dirs[name], r.recipes[name]['meta.yaml'], should_pass_df
        meta = yaml.load(meta)
        if expect_pass:
            assert func(recipe, meta, df) is None, "lint did not pass"
        else:
            assert func(recipe, meta, df) is not None, "lint did not fail"

    for contents in should_pass:
        _run(contents, expect_pass=True)

    for contents in should_fail:
        _run(contents, expect_pass=False)


def test_empty_build_section():
    r = Recipes(
        '''
        empty_build_section:
          meta.yaml: |
            package:
              name: empty_build_section
              version: "0.1"
            build:
        ''', from_string=True)
    r.write_recipes()
    # access to contents of possibly empty build section can happen in
    # `should_be_noarch` and `should_not_be_noarch`
    registry = [lint_functions.should_be_noarch, lint_functions.should_not_be_noarch]
    res = linting.lint(r.recipe_dirs.values(), config={}, df=None, registry=registry)
    assert res is None


def test_lint_skip_in_recipe():

    # should fail (note we're only linting `missing_home`)
    r = Recipes(
        '''
        missing_home:
          meta.yaml: |
            package:
              name: missing_home
              version: "0.1"
        ''', from_string=True)
    r.write_recipes()
    res = linting.lint(r.recipe_dirs.values(), config={}, df=None, registry=[lint_functions.missing_home])
    assert res is not None


    # should now pass with the extra:skip-lints (only linting for `missing_home`)
    r = Recipes(
        '''
        missing_home:
          meta.yaml: |
            package:
              name: missing_home
              version: "0.1"
            extra:
              skip-lints:
                - missing_home
        ''', from_string=True)
    r.write_recipes()
    res = linting.lint(r.recipe_dirs.values(), config={}, df=None, registry=[lint_functions.missing_home])
    assert res is None

    # should pass; minimal recipe needs to skip these lints
    r = Recipes(
        '''
        missing_home:
          meta.yaml: |
            package:
              name: missing_home
              version: "0.1"
            extra:
              skip-lints:
                - missing_home
                - missing_license
                - no_tests
        ''', from_string=True)
    r.write_recipes()
    res = linting.lint(r.recipe_dirs.values(), config={}, df=None)
    assert res is not None


def test_missing_home():
    run_lint(
        func_name='missing_home',
        should_pass='''
        missing_home:
          meta.yaml: |
            package:
              name: missing_home
              version: "0.1"
            about:
              home: "http://bioconda.github.io"
        ''',
        should_fail='''
        missing_home:
          meta.yaml: |
            package:
              name: missing_home
              version: "0.1"
        ''')


def test_missing_summary():
    run_lint(
        func_name='missing_summary',
        should_pass='''
        missing_summary:
          meta.yaml: |
            package:
              name: missing_summary
              version: "0.1"
            about:
              summary: "tool description"
        ''',
        should_fail='''
        missing_summary:
          meta.yaml: |
            package:
              name: missing_summary
              version: "0.1"
        ''')


def test_missing_license():
    run_lint(
        func_name='missing_license',
        should_pass='''
        missing_license:
          meta.yaml: |
            package:
              name: missing_license
              version: "0.1"
            about:
              license: "MIT"
        ''',
        should_fail='''
        missing_license:
          meta.yaml: |
            package:
              name: missing_license
              version: "0.1"
        ''')


def test_missing_tests():
    run_lint(
        func_name='missing_tests',
        should_pass=['''
        missing_tests:
          meta.yaml: |
            package:
              name: missing_tests
              version: "0.1"
            test:
              commands: "ls"
        ''',
        '''
        missing_tests:
          meta.yaml: |
            package:
              name: missing_tests
              version: "0.1"
          run_test.sh: ""
        ''',
        '''
        missing_tests:
          meta.yaml: |
            package:
              name: missing_tests
              version: "0.1"
          run_test.py: ""
        ''',
                    ],
        should_fail='''
        missing_tests:
          meta.yaml: |
            package:
              name: missing_tests
              version: "0.1"
          run_tst.sh: ""
        ''')


def test_missing_hash():
    run_lint(
        func_name='missing_hash',
        should_pass=['''
        missing_hash:
          meta.yaml: |
            package:
              name: missing_hash
              version: "0.1"
            source:
              md5: 11111111111111111111111111111111
        ''',
        # Should pass when source section is missing
        '''
        missing_hash:
          meta.yaml: |
            name: missing_hash
            version: "0.1"'''],
        should_fail='''
        missing_hash:
          meta.yaml: |
            package:
              name: missing_hash
              version: "0.1"
            source:
              fn: "a.txt"
        ''')


def test_uses_git_url():
    run_lint(
        func_name='uses_git_url',
        should_pass=['''
        uses_git_url:
          meta.yaml: |
            package:
              name: uses_git_url
              version: "0.1"
            source:
              fn: "a.txt"
        ''',
        '''
        uses_git_url:
          meta.yaml: |
            name: uses_git_url
            version: "0.1"'''],
        should_fail='''
        uses_git_url:
          meta.yaml: |
            package:
              name: uses_git_url
              version: "0.1"
            source:
              git_url: https://github.com/bioconda/bioconda.git
        ''')


def test_uses_perl_threaded():
    run_lint(
        func_name='uses_perl_threaded',
        should_pass=['''
        uses_perl_threaded:
          meta.yaml: |
            package:
              name: uses_perl_threaded
              version: "0.1"
            requirements:
              build:
                - perl
              run:
                - perl
        ''',
        '''
        uses_perl_threaded:
          meta.yaml: |
            package:
              name: uses_perl_threaded
              version: "0.1"
            requirements:
              run:
                - perl
        ''',
        '''
        uses_perl_threaded:
          meta.yaml: |
            package:
              name: uses_perl_threaded
              version: "0.1"
            requirements:
              build:
                - perl
        ''',
        '''
        uses_perl_threaded:
          meta.yaml: |
            package:
              name: uses_perl_threaded
              version: "0.1"
        '''],
        should_fail=[
        '''
        uses_perl_threaded:
          meta.yaml: |
            package:
              name: uses_perl_threaded
              version: "0.1"
            requirements:
              build:
                - perl-threaded
        ''',
        '''
        uses_perl_threaded:
          meta.yaml: |
            package:
              name: uses_perl_threaded
              version: "0.1"
            requirements:
              run:
                - perl-threaded
        ''',
        '''
        uses_perl_threaded:
          meta.yaml: |
            package:
              name: uses_perl_threaded
              version: "0.1"
            requirements:
              run:
                - perl-threaded
              build:
                - perl-threaded
        '''])

def test_uses_javajdk():
    run_lint(
        func_name='uses_javajdk',
        should_pass=['''
        uses_javajdk:
          meta.yaml: |
            package:
              name: uses_javajdk
              version: "0.1"
            requirements:
              build:
                - openjdk
              run:
                - openjdk
        ''',
        '''
        uses_javajdk:
          meta.yaml: |
            package:
              name: uses_javajdk
              version: "0.1"
            requirements:
              run:
                - openjdk
        ''',
        '''
        uses_javajdk:
          meta.yaml: |
            package:
              name: uses_javajdk
              version: "0.1"
            requirements:
              build:
                - openjdk
        ''',
        '''
        uses_javajdk:
          meta.yaml: |
            package:
              name: uses_javajdk
              version: "0.1"
        '''],
        should_fail=[
        '''
        uses_javajdk:
          meta.yaml: |
            package:
              name: uses_javajdk
              version: "0.1"
            requirements:
              build:
                - java-jdk
        ''',
        '''
        uses_javajdk:
          meta.yaml: |
            package:
              name: uses_javajdk
              version: "0.1"
            requirements:
              run:
                - java-jdk
        ''',
        '''
        uses_javajdk:
          meta.yaml: |
            package:
              name: uses_javajdk
              version: "0.1"
            requirements:
              run:
                - java-jdk
              build:
                - java-jdk
        '''])


def test_uses_setuptools():
    run_lint(
        func_name='uses_setuptools',
        should_pass=[
        '''
        uses_setuptools:
          meta.yaml: |
            package:
              name: uses_setuptools
              version: "0.1"
        ''',
        '''
        uses_setuptools:
          meta.yaml: |
            package:
              name: uses_setuptools
              version: "0.1"
            requirements:
              build:
                - setuptools
        '''],

        should_fail='''
        uses_setuptools:
          meta.yaml: |
            package:
              name: uses_setuptools
              version: "0.1"
            requirements:
              run:
                - setuptools
        ''',)


def test_has_windows_bat_file():
    run_lint(
        func_name='has_windows_bat_file',
        should_pass='''
        has_windows_bat_file:
          meta.yaml: |
            package:
              name: has_windows_bat_file
              version: "0.1"
        ''',

        should_fail=[
        '''
        has_windows_bat_file:
          meta.yaml: |
            package:
              name: has_windows_bat_file
              version: "0.1"
          build.bat: ""
        ''',
        '''
        has_windows_bat_file:
          meta.yaml: |
            package:
              name: has_windows_bat_file
              version: "0.1"
          any.bat: ""
        ''',]
    )

def test_should_not_be_noarch():
    run_lint(
        func_name='should_not_be_noarch',
        should_pass=[
        '''
        should_not_be_noarch:
          meta.yaml: |
            package:
              name: should_not_be_noarch
              version: "0.1"
            build:
              noarch: python
        ''',
        '''
        should_not_be_noarch:
          meta.yaml: |
            package:
              name: should_not_be_noarch
              version: "0.1"
            build:
              noarch: python
              skip: False
        ''',
        ],
        should_fail=[
        '''
        should_not_be_noarch:
          meta.yaml: |
            package:
              name: should_not_be_noarch
              version: "0.1"
            build:
              noarch: python
            requirements:
              build:
                - gcc
        ''',
        '''
        should_not_be_noarch:
          meta.yaml: |
            package:
              name: should_not_be_noarch
              version: "0.1"
            build:
              noarch: python
              skip: True  # [osx]
        ''',
        '''
        should_not_be_noarch:
          meta.yaml: |
            package:
              name: should_not_be_noarch
              version: "0.1"
            build:
              noarch: python
              skip: False
            requirements:
              build:
                - gcc
        ''',
        ]
    )



def test_setup_py_install_args():
    run_lint(
        func_name='setup_py_install_args',
        should_pass=[
        '''
        setup_py_install_args:
          meta.yaml: |
            package:
              name: setup_py_install_args
              version: "0.1"
        ''',
        '''
        setup_py_install_args:
          meta.yaml: |
            package:
              name: setup_py_install_args
              version: "0.1"
          build.sh: |
            $PYTHON setup.py install
        ''',
        '''
        setup_py_install_args:
          meta.yaml: |
            package:
              name: setup_py_install_args
              version: "0.1"
            build:
              script: $PYTHON setup.py install
        ''',
        '''
        setup_py_install_args:
          meta.yaml: |
            package:
              name: setup_py_install_args
              version: "0.1"
            requirements:
              build:
                - setuptools
          build.sh: |
            $PYTHON setup.py install --single-version-externally-managed --report=a.txt
        ''',
        '''
        setup_py_install_args:
          meta.yaml: |
            package:
              name: setup_py_install_args
              version: "0.1"
            requirements:
              build:
                - setuptools
          build.sh: |
            $PYTHON setup.py install \\
            --single-version-externally-managed --report=a.txt
        ''',
        '''
        setup_py_install_args:
          meta.yaml: |
            package:
              name: setup_py_install_args
              version: "0.1"
            build:
              script: $PYTHON setup.py install --single-version-externally-managed --report=a.txt
        ''',
        ],
        should_fail=[
        '''
        setup_py_install_args:
          meta.yaml: |
            package:
              name: setup_py_install_args
              version: "0.1"
            requirements:
              build:
                - setuptools
          build.sh: |
            $PYTHON setup.py install
        ''',
        '''
        setup_py_install_args:
          meta.yaml: |
            package:
              name: setup_py_install_args
              version: "0.1"
            requirements:
              build:
                - setuptools
            build:
              script: $PYTHON setup.py install
        ''',
        ]
    )
