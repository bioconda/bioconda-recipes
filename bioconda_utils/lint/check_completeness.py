"""Completeness

Verify that the recipe is not missing anything essential.
"""

import os
from . import LintCheck, ERROR, WARNING, INFO


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

