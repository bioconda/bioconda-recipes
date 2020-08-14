"""Deprecated packages and syntax

"""

from . import LintCheck, ERROR, WARNING, INFO


class uses_perl_threaded(LintCheck):
    """The recipe uses ``perl-threaded``

    Please use ``perl`` instead.

    """
    def check_deps(self, deps):
        if 'perl-threaded' in deps:
            self.message(data=True)

    def fix(self, _message, _data):
        self.recipe.replace('perl-threaded', 'perl',
                            within=('requirements', 'outputs'))
        self.recipe.render()
        return True


class uses_javajdk(LintCheck):
    """The recipe uses ``java-jdk``

    Please use ``openjdk`` instead.

    """
    def check_deps(self, deps):
        if 'java-jdk' in deps:
            self.message(data=True)

    def fix(self, _message, _data):
        self.recipe.replace('java-jdk', 'openjdk',
                            within=('requirements', 'outputs'))
        return True


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
                self.message(section=path, data=True)

    def fix(self, _message, _data):
        self.recipe.replace('numpy x.x', 'numpy',
                            within=('requirements', 'outputs'))
        return True


class uses_matplotlib(LintCheck):
    """The recipe uses ``matplotlib``, but ``matplotlib-base`` is recommended

    The ``matplotlib`` dependency should be replaced with ``matplotlib-base``
    unless the package explicitly needs the PyQt interactive plotting backend.

    """
    def check_deps(self, deps):
        if 'matplotlib' in deps:
            self.message(data=True)

    def fix(self, _message, _data):
        self.recipe.replace('matplotlib', 'matplotlib-base',
                            within=('requirements', 'outputs'))
        return True
