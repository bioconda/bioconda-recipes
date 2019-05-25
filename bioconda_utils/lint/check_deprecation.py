"""Deprecated packages and syntax

"""

from . import LintCheck, ERROR, WARNING, INFO


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

