Linting
=======

In order to ensure high-quality packages, we now perform routine checks on each 
recipe (called `linting
<http://stackoverflow.com/questions/8503559/what-is-linting>`_). By default,
linting is performed on any recipes that have changed relative to the master
branch. The travis-ci build will fail if any of the linting checks fail. Below
is a list of the checks performed and how to fix them if they fail.

Skipping a linting test
-----------------------
While only recommended in special cases, it is possible to skip specific
linting tests on a commit by using special text in the commit message, `[lint
skip $FUNCTION for $RECIPE]` where `$FUNCTION` is the name of the function to
skip and `$RECIPE` is the path to the recipe directory for which this test
should be skipped.

For example, if the linter reports a `uses_setuptools` issue for
`recipes/mypackage/0.1`, but you are certain the package really needs
setuptools, you can add `[lint skip uses_setuptools for recipes/mypackage/0.1]`
to the commit message and this linting test will be skipped on Travis-CI.
Multiple tests can be skipped by adding additional special text. For example,
`[lint skip uses_setuptools for recipes/pkg1] [lint skip in_other_channels for
recipes/pkg2]`.

Technically we check for the regular expression `\[\s*lint skip (?P<func>\w+)
for (?P<recipe>.*?)\s*\]` in the commit message of the HEAD commit. However,
often we want to test changes locally without committing.  When running
`simulate-travis.py` locally for testing, you can add the same special text to
a temporary environment variable `LINT_SKIP`. The same example above could be
tested locally like this without having to make a commit::

    LINT_SKIP="[lint skip uses_setuptools for recipes/mypackage/0.1]" ./simulate-travis.py

Linting functions
-----------------

`in_other_channels`
~~~~~~~~~~~~~~~~~~
The package exists in another dependent channel (currently conda-forge, r, and
defaults). In special cases this can be overridden, for example if
a bioconda-specific patch is required. However it is almost always better to
fix the original package in the other channel.

`already_in_bioconda`
~~~~~~~~~~~~~~~~~~~~~
The current package version, build, and platform (linux/osx) already exists in
the bioconda chennel. Increase the version number or `build number
<https://conda.io/docs/building/meta-yaml.html#build-number-and-string>`_ as
appropriate.

`missing_home`
~~~~~~~~~~~~~~
No homepage URL. Add the url in the `about section
<https://conda.io/docs/building/meta-yaml.html#about-section>`_.

`missing_summary`
~~~~~~~~~~~~~~~~~
Missing a summary; add a descriptive summary in the `about
section <https://conda.io/docs/building/meta-yaml.html#about-section>`_.

`missing_license`
~~~~~~~~~~~~~~~~~
No license provided. Add the license in the `about section
<https://conda.io/docs/building/meta-yaml.html#about-section>`_.

`missing_tests`
~~~~~~~~~~~~~~~
No tests provided. Add basic tests to ensure the software gets installed; see
:ref:`tests` for more info.

`missing_hash`
~~~~~~~~~~~~~~
A hash in the `source section
<https://conda.io/docs/building/meta-yaml.html#source-section>`_ is required.
aSee :ref:`hashes` for more info.

`uses_git_url`
~~~~~~~~~~~~~~
The source section uses a git URL. While this is supported by conda, we prefer
to not use this method since it is not always reproducible.  See
:ref:`stable-url` for more info.

`uses_perl_threaded`
~~~~~~~~~~~~~~~~~~~~
Previously bioconda used `perl-threaded` as a dependency for Perl packages, but
now we are using `perl` instead.

`uses_javajdk`
~~~~~~~~~~~~~~
Previously bioconda used `java-jdk` as a dependency for Java packages, but now
we are using `openjdk` instead.

`uses_setuptools`
~~~~~~~~~~~~~~~~~
`setuptools` is typically used to install dependencies for Python packages but
most of the time this is not needed within a conda package; rather, all
dependencies should be explicitly defined. Some packages do need setuptools, in
which case this can be overridden.

`has_windows_bat_file`
~~~~~~~~~~~~~~~~~~~~~~
Since bioconda does not support Windows, any `*.bat` files should be removed
from the recipe.
