"""
Lint Checks for Recipe Linter

See :py:mod:`bioconda_utils.lint` for an introduction to writing
new checks or updating existing checks.
"""
# (i.e., look into the __init__.py in this folder)

import glob
import os
import re

from .. import utils
from . import LintCheck, ERROR, INFO


class in_other_channels(LintCheck):
    """A package of the same name already exists in another channel

    Bioconda and Conda-Forge occupy the same name space and have
    agreed not to add packages if a package of the same name is
    already present in the respective other channel.

    If this is a new package, pease choose a different name
    (e.g. append ``-bio``).

    If you are updating a package, please continue in the package's
    new home at conda-forge.

    """
    def check_recipe(self, recipe):
        channels = utils.RepoData().get_package_data(key="channel", name=recipe.name)
        if set(channels) - set(('bioconda',)):
            self.message(section='package/name')


class build_number_needs_bump(LintCheck):
    """The recipe build number should be incremented

    A package with the same name and version and a build number at
    least as high as specified in the recipe already exists in the
    channel. Please increase the build number.

    """
    def check_recipe(self, recipe):
        bldnos = utils.RepoData().get_package_data(
            key="build_number",
            name=recipe.name, version=recipe.version)
        if bldnos and recipe.build_number <= max(bldnos):
            self.message('build/number')


class missing_build_number(LintCheck):
    """The recipe is missing a build number

    Please add::

        build:
            number: 0
    """
    def check_recipe(self, recipe):
        if not recipe.get('build/number', ''):
            self.message(section='build')


class missing_home(LintCheck):
    """The recipe is missing a homepage URL

    Please add::

       about:
          home: <URL to homepage>

    """
    def check_recipe(self, recipe):
        if not recipe.get('about/home', ''):
            self.message(section='about')


class missing_summary(LintCheck):
    """The recipe is missing a summary

    Please add::

       about:
         summary: One line briefly describing package

    """
    def check_recipe(self, recipe):
        if not recipe.get('about/summary', ''):
            self.message(section='about')


class missing_license(LintCheck):
    """The recipe is missing the ``about/license`` key.

    Please add::

        about:
           license: <name of license>

    """
    def check_recipe(self, recipe):
        if not recipe.get('about/license', ''):
            self.message(section='about')


class missing_tests(LintCheck):
    """The recipe is missing tests.

    Please add::

        test:
            commands:
               - some_command

    and/or::

        test:
            imports:
               - some_module


    and/or any file named ``run_test.py`, ``run_test.sh`` or
    ``run_test.pl`` executing tests.

    """
    test_files = ['run_test.py', 'run_test.sh', 'run_test.pl']

    def check_recipe(self, recipe):
        if any(os.path.exists(os.path.join(recipe.dir, f))
               for f in self.test_files):
            return
        if recipe.get('test/commands', '') or recipe.get('test/imports', ''):
            return
        if recipe.get('test', False) is not False:
            self.message(section='test')
        else:
            self.message()


class missing_hash(LintCheck):
    """The recipe is missing a checksum for a source file

    Please add::

       source:
         sha256: checksum-value

    """
    checksum_names = ('md5', 'sha1', 'sha256')

    def check_source(self, source, section):
        if not any(source.get(chk) for chk in self.checksum_names):
            self.message(section=section)


class uses_git_url(LintCheck):
    """The recipe downloads source from git

    Please build from source archives and don't use the ``git_url``
    feature of conda.

    """
    def check_source(self, source, section):
        if 'git_url' in source:
            self.message(section=section + '/git_url')


class uses_perl_threaded(LintCheck):
    """The recipe uses ``perl-threaded``

    Please use ``perl`` instead.

    """
    def check_recipe(self, recipe):
        if 'perl-threaded' in recipe.get_deps():
            self.message()


class uses_javajdk(LintCheck):
    """The recipe uses ``java-jdk``

    Please use ``openjdk`` instead.

    """
    def check_recipe(self, recipe):
        if 'java-jdk' in recipe.get_deps():
            self.message()


class uses_setuptools(LintCheck):
    """The recipe uses setuptools in run depends

    Most Python packages only need setuptools during installation.
    Check if the package really needs setuptools (e.g. because it uses
    pkg_resources or setuptools console scripts).

    """
    severity = INFO

    def check_recipe(self, recipe):
        if 'setuptools' in recipe.get_deps('run'):
            self.message()


class has_windows_bat_file(LintCheck):
    """The recipe directory contains a ``bat`` file.

    Bioconda does not and will never build Windows packages.

    Please remove any ``*.bat`` files generated by ``conda skeleton``
    from the recipe directory.

    """
    def check_recipe(self, recipe):
        for fname in glob.glob(os.path.join(recipe.dir, '*.bat')):
            self.message(fname=fname)


# Noarch or not checks:
#
# - Python packages that use no compiler should be
#   a) Marked ``noarch: python``
#   b) Not use ``skip: True  # [...]`` except for osx/linux,
#      but use ``- python [<>]3``
# - Python packages that use a compiler should be
#   a) NOT marked ``noarch: python``
#   b) Not use ``- python [<>]3``,
#      but use ``skip: True  # [py[23]k]``

class should_be_noarch_python(LintCheck):
    """The recipe should be build as ``noarch``

    Please add::

        build:
          noarch: python

    Python packages that don't require a compiler to build are
    normally architecture independent and go into the ``noarch``
    subset of packages.

    """
    def check_deps(self, deps):
        if 'python' not in deps:
            return  # not a python package
        if any(dep.startswith('compiler_') for dep in deps):
            return  # not compiled
        if self.recipe.get('build/noarch', None) == 'python':
            return  # already marked noarch: python
        self.message(section='build')


class should_be_noarch(LintCheck):
    """The recipe should be build as ``noarch``

    Please add::

        build:
          noarch: True

    Packages that don't require a compiler to build are normally
    architecture independent and go into the ``noarch`` subset of
    packages.

    """
    requires = ['should_be_noarch_python']
    def check_deps(self, deps):
        if any(dep.startswith('compiler_') for dep in deps):
            return  # not compiled
        if self.recipe.get('build/noarch', None) == 'python':
            return  # already marked noarch: python
        self.message(section='build')


class should_not_use_skip_python(LintCheck):
    """The recipe should be noarch and not use python based skipping

    Please use::

       requirements:
          build:
            - python >3  # or <3
          run:
            - python >3  # or <3

    The ``build: skip: True`` feature only works as expected for
    packages built specifically for each "platform" (i.e. Python
    version and OS). This package should be ``noarch`` and not use
    skips.

    """
    bad_skip_terms = ('py2k', 'py3k', 'python')

    def check_deps(self, deps):
        if 'python' not in deps:
            return  # not a python package
        if any(dep.startswith('compiler_') for dep in deps):
            return  # not compiled
        if self.recipe.get('build/skip', None) is None:
            return  # no build: skip: section
        skip_line = self.recipe.get_raw('build/skip')
        if not any(term in skip_line for term in self.bad_skip_terms):
            return  # no offending skip terms
        self.message(section='build/skip')


class should_not_be_noarch_compiler(LintCheck):
    """The recipe uses a compiler but is marked noarch

    Recipes using a compiler should not be marked noarch.

    Please remove the ``build: noarch:`` section.

    """
    def check_deps(self, deps):
        if not any(dep.startswith('compiler_') for dep in deps):
            return  # not compiled
        if self.recipe.get('build/noarch', False) is False:
            return  # no noarch, or noarch=False
        self.message(section='build/noarch')


class should_not_be_noarch_skip(LintCheck):
    """The recipe uses ``skip: True`` but is marked noarch

    Recipes marked as ``noarch`` cannot use skip.

    """
    def check_recipe(self, recipe):
        if self.recipe.get('build/noarch', False) is False:
            return  # no noarch, or noarch=False
        if self.recipe.get('build/skip', False) is False:
            return  # no skip or skip=False
        self.message(section='build/noarch')


class setup_py_install_args(LintCheck):
    """The recipe uses setuptools without required arguments

    Please use::

        $PYTHON setup.py install --single-version-externally-managed --record=record.txt

    The parameters are required to avoid ``setuptools`` trying (and
    failing) to install ``certifi`` when a package this recipe
    requires defines entrypoints in its ``setup.py``.

    """
    def _check_line(self, line: str) -> bool:
        """Check a line for a broken call to setup.py"""
        if 'setup.py install' not in line:
            return True
        if '--single-version-externally-managed' in line:
            return True
        return False

    def check_deps(self, deps):
        if 'setuptools' not in deps:
            return  # no setuptools, no problem

        if not self._check_line(self.recipe.get('build/script', '')):
            self.message(section='build/script')

        try:
            with open(os.path.join(self.recipe.dir, 'build.sh')) as buildsh:
                for n, line in enumerate(buildsh):
                    if not self._check_line(line):
                        self.message(fname='build.sh', line=n)
        except FileNotFoundError:
            pass


class extra_identifiers_not_list(LintCheck):
    """The extra/identifiers section must be a list

    Example::

        extra:
           identifiers:
              - doi:123

    """
    def check_recipe(self, recipe):
        identifiers = recipe.get('extra/identifiers', None)
        if identifiers and not isinstance(identifiers, list):
            self.message(section='extra/identifiers')


class extra_identifiers_not_string(LintCheck):
    """Each item in the extra/identifiers section must be a string

    Example::

        extra:
           identifiers:
              - doi:123

    Note that there is no space around the colon

    """
    requires = [extra_identifiers_not_list]

    def check_recipe(self, recipe):
        identifiers = recipe.get('extra/identifiers', [])
        for n, identifier in enumerate(identifiers):
            if not isinstance(identifier, str):
                self.message(section=f'extra/identifiers/{n}')


class extra_identifiers_missing_colon(LintCheck):
    """Each item in the extra/identifiers section must be of form ``type:value``

    Example::

        extra:
           identifiers:
              - doi:123

    """
    requires = [extra_identifiers_not_string]

    def check_recipe(self, recipe):
        identifiers = recipe.get('extra/identifiers', [])
        for n, identifier in enumerate(identifiers):
            if ':' not in identifier:
                self.message(section=f'extra/identifiers/{n}')


class extra_skip_lints_not_list(LintCheck):
    """The extra/skip-lints section must contain a list"""
    def check_recipe(self, recipe):
        if not isinstance(recipe.get('extra/skip-lints', []), list):
            self.message(section='extra/skip-lints')


class deprecated_numpy_spec(LintCheck):
    """The recipe contains a deprecated numpy spec

    Please remove the ``x.x`` - pinning is now handled automatically.

    """
    def check_deps(self, deps):
        if 'numpy' not in deps:
            return
        for path in deps['numpy']:
            line, _, _ = self.recipe.get_raw(path).partition('#')
            if 'x.x' in line:
                self.message(section=path)


class should_not_use_fn(LintCheck):
    """The recipe uses source/fn

    There is no need to specify the filename as the URL should give a name
    and it will in most cases be unpacked automatically.
    """
    def check_source(self, source, section):
        if 'fn' in source:
            self.message(section=section+'/fn')


class should_use_compilers(LintCheck):
    """The recipe requires a compiler directly

    Since version 3, ``conda-build`` uses a special syntax to require
    compilers for a given language matching the architecture for
    which a package is being build. Please use::

        requirements:
           build:
             - {{ compiler('language') }}

    Where language is one of ``c``, ``cxx``, ``fortran``, ``go`` or
    ``cgo``. You can specify multiple compilers if needed.

    There is no need to add ``libgfortran``, ``libgcc``, or
    ``toolchain`` to the dependencies as this will be handled by
    conda-build itself.

    """
    compilers = ('gcc', 'llvm', 'libgfortran', 'libgcc', 'go', 'cgo',
                 'toolchain')

    def check_deps(self, deps):
        for compiler in self.compilers:
            for location in deps.get(compiler, []):
                self.message(section=location)


class compilers_must_be_in_build(LintCheck):
    """The recipe requests a compiler in a section other than build

    Please move the ``{{ compiler('language') }}`` line into the
    ``requirements: build:`` section.

    """
    def check_deps(self, deps):
        for dep in deps:
            if dep.startswith('compiler_'):
                for location in deps[dep]:
                    if 'run' in location or 'host' in location:
                        self.message(section=location)


class recipe_is_blacklisted(LintCheck):
    """The recipe is currently blacklisted and will not be built.

    If you are intending to repair this recipe, remove it from
    the build fail blacklist.
    """
    def __init__(self, linter):
        super().__init__(linter)
        self.blacklist = linter.get_blacklist()

    def check_recipe(self, recipe):
        if recipe.name in self.blacklist:
            self.message(section='package/name')


class folder_and_package_name_must_match(LintCheck):
    """The recipe folder and package name do not match.

    For clarity, the name of the folder the ``meta.yaml`` resides,
    in and the name of the toplevel package should match.
    """
    def check_recipe(self, recipe):
        recipe_base_folder, _, _ = recipe.reldir.partition('/')
        if recipe.name !=  recipe_base_folder:
            self.message(section='package/name')
        print(recipe.name, recipe.reldir, recipe_base_folder)


class gpl_requires_license_distributed(LintCheck):
    """The recipe packages GPL software but is missing copy of license.

    The GPL requires that a copy of the license accompany all distributions
    of the software. Please add::

        about:
            license_file: name_of_license_file

    If the upstream tar ball does not include a copy, please ask the
    authors of the software to add it to their distribution archive.
    """
    requires = [missing_license]

    def check_recipe(self, recipe):
        if 'gpl' in recipe.get('about/license').lower():
            if not recipe.get('about/license_file', ''):
                self.message('about/license')
