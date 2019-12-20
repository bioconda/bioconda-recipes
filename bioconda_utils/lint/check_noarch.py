"""Use of ``noarch`` and ``skip``

When to use ``noarch`` and when to use ``skip`` or pin the interpreter
is non-intuitive and idiosynractic due to ``conda`` legacy
behavior. These checks aim at getting the right settings.

"""

import re

from . import LintCheck, ERROR, WARNING, INFO


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
        if all('build' not in loc for loc in deps['python']):
            return  # only uses python in run/host
        if any(dep.startswith('compiler_') for dep in deps):
            return  # not compiled
        if self.recipe.get('build/noarch', None) == 'python':
            return  # already marked noarch: python
        self.message(section='build', data=True)

    def fix(self, _message, _data):
        self.recipe.set('build/noarch', 'python')
        return True


class should_be_noarch_generic(LintCheck):
    """The recipe should be build as ``noarch``

    Please add::

        build:
          noarch: generic

    Packages that don't require a compiler to build are normally
    architecture independent and go into the ``noarch`` subset of
    packages.

    """
    requires = ['should_be_noarch_python']
    def check_deps(self, deps):
        if any(dep.startswith('compiler_') for dep in deps):
            return  # not compiled
        if self.recipe.get('build/noarch', None):
            return  # already marked noarch
        self.message(section='build', data=True)

    def fix(self, _message, _data):
        self.recipe.set('build/noarch', 'generic')
        return True


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


class should_not_be_noarch_source(LintCheck):
    """The recipe uses per platform sources and cannot be noarch

    You are downloading different upstream sources for each
    platform. Remove the noarch section or use just one source for all
    platforms.
    """
    _pat = re.compile(r'# +\[.*\]')

    def check_source(self, source, section):
        if self.recipe.get('build/noarch', False) is False:
            return  # no noarch, or noarch=False
        # just search the entire source entry for a comment
        if self._pat.search(self.recipe.get_raw(f"{section}")):
            self.message(section)
