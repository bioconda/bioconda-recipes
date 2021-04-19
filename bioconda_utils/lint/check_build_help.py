"""Build tool usage

These checks catch errors relating to the use of ``-
{{compiler('xx')}}`` and ``setuptools``.

"""

import os

from . import LintCheck, ERROR, WARNING, INFO


class should_use_compilers(LintCheck):
    """The recipe requires a compiler directly

    Since version 3, ``conda-build`` uses a special syntax to require
    compilers for a given language matching the architecture for which
    a package is being build. Please use::

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


class setup_py_install_args(LintCheck):
    """The recipe uses setuptools without required arguments

    Please use::

        $PYTHON setup.py install --single-version-externally-managed --record=record.txt

    The parameters are required to avoid ``setuptools`` trying (and
    failing) to install ``certifi`` when a package this recipe
    requires defines entrypoints in its ``setup.py``.

    """
    @staticmethod
    def _check_line(line: str) -> bool:
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
                for num, line in enumerate(buildsh):
                    if not self._check_line(line):
                        self.message(fname='build.sh', line=num)
        except FileNotFoundError:
            pass


class cython_must_be_in_host(LintCheck):
    """Cython should be in the host section

    Move cython to ``host``::

      requirements:
        host:
          - cython
    """
    def check_deps(self, deps):
        if 'cython' in deps:
            if any('host' not in location
                   for location in deps['cython']):
                self.message()


class cython_needs_compiler(LintCheck):
    """Cython generates C code, which will need to be compiled

    Add the compiler to the recipe::

      requirements:
        build:
          - {{ compiler('c') }}

    """
    severity = WARNING
    def check_deps(self, deps):
        if 'cython' in deps and 'compiler_c' not in deps:
            self.message()
