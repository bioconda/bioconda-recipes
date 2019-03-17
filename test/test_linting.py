from helpers import Recipes
from bioconda_utils import lint_functions
from bioconda_utils import linting, utils
from bioconda_utils.recipe import Recipe


def run_lint(
    func,
    should_pass,
    should_fail
):
    """
    Helper function to run a lint function on a set of recipes that should pass
    and that should fail.

    Recall each lint function takes recipe path, parsed meta.yaml, and
    dataframe of channel info.

    Parameters
    ----------
    func : function
        Function to test in `bioconda_utils.lint_functions`

    should_pass, should_fail : str or list
        Recipe definitions that will be provided to `helpers.Recipes`. Each can
        be a single string or a list of strings to test.

    """

    if isinstance(should_pass, str):
        should_pass = [should_pass]
    if isinstance(should_fail, str):
        should_fail = [should_fail]

    def _run(contents, expect_pass=True):
        """
        Build the recipe and run the lint function on the rendered recipe
        """
        r = Recipes(contents, from_string=True)
        r.write_recipes()
        assert len(r.recipe_dirs) == 1
        name = list(r.recipe_dirs.keys())[0]
        recipe = Recipe.from_file(r.basedir, r.recipe_dirs[name])
        metas = []
        for platform in ["linux", "osx"]:
            config = utils.load_conda_build_config(platform=platform, trim_skip=False)
            metas.extend(utils.load_all_meta(r.recipe_dirs[name], config=config, finalize=False))
        if expect_pass:
            assert func(recipe, metas) is None, "lint did not pass"
        else:
            assert func(recipe, metas) is not None, "lint did not fail"

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
    res = linting.lint(
        r.recipe_dirs.values(),
        linting.LintArgs(registry=registry),
        basedir=r.basedir
    )
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
    res = linting.lint(
        r.recipe_dirs.values(),
        linting.LintArgs(registry=[lint_functions.missing_home]),
        basedir=r.basedir)
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
    res = linting.lint(
        r.recipe_dirs.values(),
        linting.LintArgs(registry=[lint_functions.missing_home]),
        basedir=r.basedir)
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
                - in_other_channels  # avoid triggering RepoData load
        ''', from_string=True)
    r.write_recipes()
    res = linting.lint(r.recipe_dirs.values(), linting.LintArgs(),
        basedir=r.basedir)
    assert res is not None


def test_missing_home():
    run_lint(
        func=lint_functions.missing_home,
        should_pass=[
            '''
            missing_home:
              meta.yaml: |
                package:
                  name: missing_home
                  version: "0.1"
                about:
                  home: "http://bioconda.github.io"
            ''',
        ],
        should_fail=[
            '''
            missing_home:
              meta.yaml: |
                package:
                  name: missing_home
                  version: "0.1"
            ''',
            '''
            missing_home:
              meta.yaml: |
                package:
                  name: missing_home
                  version: "0.1"
                about:
                  home: ""
            ''',
        ],
    )


def test_missing_summary():
    run_lint(
        func=lint_functions.missing_summary,
        should_pass=[
            '''
            missing_summary:
              meta.yaml: |
                package:
                  name: missing_summary
                  version: "0.1"
                about:
                  summary: "tool description"
            ''',
        ],
        should_fail=[
            '''
            missing_summary:
              meta.yaml: |
                package:
                  name: missing_summary
                  version: "0.1"
            ''',
            '''
            missing_summary:
              meta.yaml: |
                package:
                  name: missing_summary
                  version: "0.1"
                about:
                  summary: ""
            ''',
        ],
    )


def test_missing_license():
    run_lint(
        func=lint_functions.missing_license,
        should_pass=[
            '''
            missing_license:
              meta.yaml: |
                package:
                  name: missing_license
                  version: "0.1"
                about:
                  license: "MIT"
            ''',
        ],
        should_fail=[
            '''
            missing_license:
              meta.yaml: |
                package:
                  name: missing_license
                  version: "0.1"
            ''',
            '''
            missing_license:
              meta.yaml: |
                package:
                  name: missing_license
                  version: "0.1"
                about:
                  license: ""
            ''',
        ],
    )


def test_missing_tests():
    run_lint(
        func=lint_functions.missing_tests,
        should_pass=[
            '''
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
        should_fail=[
            '''
            missing_tests:
              meta.yaml: |
                package:
                  name: missing_tests
                  version: "0.1"
              run_tst.sh: ""
            ''',
            '''
            missing_tests:
              meta.yaml: |
                package:
                  name: missing_tests
                  version: "0.1"
                test:
                  # empty test section
            ''',
        ],
    )


def test_missing_hash():
    run_lint(
        func=lint_functions.missing_hash,
        should_pass=[
            '''
            missing_hash:
              meta.yaml: |
                package:
                  name: md5hash
                  version: "0.1"
                source:
                  md5: 11111111111111111111111111111111
            ''',
            '''
            missing_hash:
              meta.yaml: |
                package:
                  name: md5hash_list
                  version: "0.1"
                source:
                  - md5: 11111111111111111111111111111111
            ''',
            # Should pass when source section is missing
            '''
            missing_hash:
              meta.yaml: |
                package:
                  name: metapackage
                  version: "0.1"
            ''',
        ],
        should_fail=[
            '''
            missing_hash:
              meta.yaml: |
                package:
                  name: missing_hash
                  version: "0.1"
                source:
                  fn: "a.txt"
            ''',
            '''
            missing_hash:
              meta.yaml: |
                package:
                  name: empty_hash
                  version: "0.1"
                source:
                  fn: "a.txt"
                  sha256: ""
            ''',
            '''
            missing_hash:
              meta.yaml: |
                package:
                  name: missing_hash_list
                  version: "0.1"
                source:
                  - fn: "a.txt"
                  - md5: 11111111111111111111111111111111
            ''',
        ],
    )


def test_uses_git_url():
    run_lint(
        func=lint_functions.uses_git_url,
        should_pass=[
            '''
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
                package:
                  name: uses_git_url
                  version: "0.1"
            ''',
            '''
            uses_git_url:
              meta.yaml: |
                package:
                  name: uses_git_url_list
                  version: "0.1"
                source:
                  - fn: "a.txt"
            ''',
        ],
        should_fail=[
            '''
            uses_git_url:
              meta.yaml: |
                package:
                  name: uses_git_url
                  version: "0.1"
                source:
                  git_url: https://github.com/bioconda/bioconda.git
            ''',
            '''
            uses_git_url:
              meta.yaml: |
                package:
                  name: uses_git_url_list
                  version: "0.1"
                source:
                  - git_url: https://github.com/bioconda/bioconda.git
            ''',
        ],
    )


def test_uses_perl_threaded():
    run_lint(
        func=lint_functions.uses_perl_threaded,
        should_pass=[
            '''
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
            ''',
        ],
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
            ''',
        ],
    )


def test_uses_javajdk():
    run_lint(
        func=lint_functions.uses_javajdk,
        should_pass=[
            '''
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
            ''',
        ],
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
            ''',
        ],
    )


def test_uses_setuptools():
    run_lint(
        func=lint_functions.uses_setuptools,
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
            ''',
        ],
        should_fail=[
            '''
            uses_setuptools:
              meta.yaml: |
                package:
                  name: uses_setuptools
                  version: "0.1"
                requirements:
                  run:
                    - setuptools
            ''',
        ],
    )


def test_has_windows_bat_file():
    run_lint(
        func=lint_functions.has_windows_bat_file,
        should_pass=[
            '''
            has_windows_bat_file:
              meta.yaml: |
                package:
                  name: has_windows_bat_file
                  version: "0.1"
            ''',
        ],
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
            ''',
        ]
    )


def test_should_not_be_noarch():
    run_lint(
        func=lint_functions.should_not_be_noarch,
        should_pass=[
            '''
            should_be_noarch1:
              meta.yaml: |
                package:
                  name: should_be_noarch1
                  version: "0.1"
                build:
                  noarch: python
            ''',
            '''
            should_be_noarch2:
              meta.yaml: |
                package:
                  name: should_be_noarch2
                  version: "0.1"
                build:
                  noarch: python
                  skip: false
            ''',
        ],
        should_fail=[
            '''
            should_not_be_noarch1:
              meta.yaml: |
                package:
                  name: should_not_be_noarch1
                  version: "0.1"
                build:
                  noarch: python
                requirements:
                  build:
                    - gcc
            ''',
            '''
            should_not_be_noarch2:
              meta.yaml: |
                package:
                  name: should_not_be_noarch2
                  version: "0.1"
                build:
                  noarch: python
                  skip: True  # [osx]
            ''',
            '''
            should_not_be_noarch3:
              meta.yaml: |
                package:
                  name: should_not_be_noarch3
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
        func=lint_functions.setup_py_install_args,
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
            ''',  # noqa: E501: line too long
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


def test_invalid_identifiers():
    run_lint(
        func=lint_functions.invalid_identifiers,
        should_pass=[
            '''
            a:
                meta.yaml: |
                  package:
                    name: a
                    version: 0.1
                  extra:
                    identifiers:
                      - doi:10.1093/bioinformatics/btr010
            ''',
        ],
        should_fail=[
            '''
            a:
                meta.yaml: |
                  package:
                    name: a
                    version: 0.1
                  extra:
                    identifiers:
                      - doi: 10.1093/bioinformatics/btr010
            ''',
            '''
            a:
                meta.yaml: |
                  package:
                    name: a
                    version: 0.1
                  extra:
                    identifiers:
                      doi: 10.1093/bioinformatics/btr010
            ''',
            '''
            a:
                meta.yaml: |
                  package:
                    name: a
                    version: 0.1
                  extra:
                    identifiers:
                      doi:10.1093/bioinformatics/btr010
            ''',
        ]
    )


def test_deprecated_numpy_spec():
    run_lint(
        func=lint_functions.deprecated_numpy_spec,
        should_pass=[
            '''
            a:
                meta.yaml: |
                  package:
                    name: a
                    version: 0.1
                  requirements:
                    build:
                      - numpy
                      - python
                    run:
                      - numpy
            ''',
        ],
        should_fail=[
            '''
            a:
                meta.yaml: |
                  package:
                    name: a
                    version: 0.1
                  requirements:
                    build:
                      - numpy x.x
                    run:
                      - numpy x.x
            ''',
        ]
    )


def test_should_use_compilers():
    run_lint(
        func=lint_functions.should_use_compilers,
        should_pass=[
            '''
            a:
                meta.yaml: |
                  package:
                    name: a
                    version: 0.1
                  requirements:
                    host:
                      - python
                    run:
                      - python
            ''',
            '''
            a:
                meta.yaml: |
                  package:
                    name: a
                    version: 0.1
                  requirements:
                    build:
                      - {{ compiler ('c') }}
            ''',
        ],
        should_fail=[
            '''
            a:
                meta.yaml: |
                  package:
                    name: a
                    version: 0.1
                  requirements:
                    build:
                      - gcc  # [linux]
            ''',
            '''
            a:
                meta.yaml: |
                  package:
                    name: a
                    version: 0.1
                  requirements:
                    run:
                      - libgcc  # [linux]
            ''',
        ]
    )


def test_compilers_must_be_in_build():
    run_lint(
        func=lint_functions.compilers_must_be_in_build,
        should_pass=[
            '''
            a:
                meta.yaml: |
                  package:
                    name: a
                    version: 0.1
                  requirements:
                    host:
                      - python
                    run:
                      - python
                    build:
                      - {{ compiler ('c') }}
            ''',
        ],
        should_fail=[
            '''
            a:
                meta.yaml: |
                  package:
                    name: a
                    version: 0.1
                  requirements:
                    run:
                      - {{ compiler("c") }}
            ''',
            '''
            a:
                meta.yaml: |
                  package:
                    name: a
                    version: 0.1
                  requirements:
                    host:
                      - {{ compiler ('c') }}
            ''',
        ]
    )


def test_should_not_use_fn():
    run_lint(
        func=lint_functions.should_not_use_fn,
        should_pass=[
            '''
            a:
                meta.yaml: |
                  package:
                    name: a
                    version: 0.1
            ''',
            '''
            a:
                meta.yaml: |
                  package:
                    name: a
                    version: 0.1
                  source:
                    url: https://bioconda.github.io/index.html
            ''',
        ],
        should_fail=[
            '''
            a:
                meta.yaml: |
                  package:
                    name: a
                    version: 0.1
                  source:
                    fn: index.html
                    url: https://bioconda.github.io/index.html
            ''',
        ]
    )


#def test_bioconductor_37():
#    run_lint(
#        func=lint_functions.bioconductor_37,
#        should_pass=[
#            '''
#            a:
#                meta.yaml: |
#                  {% set bioc = "3.6" %}
#                  package:
#                    name: a
#                    version: 0.1
#            ''',
#        ],
#        should_fail=[
#            '''
#            a:
#                meta.yaml: |
#                  {% set bioc = "3.7" %}
#                  package:
#                    name: a
#                    version: 0.1
#            ''',
#            '''
#            a:
#                meta.yaml: |
#                  {% set bioc = "release" %}
#                  package:
#                    name: a
#                    version: 0.1
#            ''',
#        ]
#    )
