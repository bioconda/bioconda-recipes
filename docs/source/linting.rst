Linting
=======

In order to ensure high-quality packages, we now perform routine checks on each
recipe (called `linting
<http://stackoverflow.com/questions/8503559/what-is-linting>`_). By default,
linting is performed on any recipes that have changed relative to the master
branch. The CircleCI build will fail if any of the linting checks fail. Below
is a list of the checks performed and how to fix them if they fail.

Skipping a linting test
-----------------------
Skipping on a per-commit basis
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
While only recommended in special cases, it is possible to skip specific
linting tests on a commit by using special text in the commit message, ``[lint
skip $FUNCTION for $RECIPE]`` where ``$FUNCTION`` is the name of the function to
skip and ``$RECIPE`` is the path to the recipe directory for which this test
should be skipped.

For example, if the linter reports a ``uses_setuptools`` issue for
``recipes/mypackage``, but you are certain the package really needs
setuptools, you can add ``[lint skip uses_setuptools for recipes/mypackage]``
to the commit message and this linting test will be skipped on CircleCI.
Multiple tests can be skipped by adding additional special text. For example,
``[lint skip uses_setuptools for recipes/pkg1] [lint skip in_other_channels for
recipes/pkg2/0.3.5]``. Note in the latter case that the second recipe has
a subdirectory for an older version.

Technically we check for the regular expression ``\[\s*lint skip (?P<func>\w+)
for (?P<recipe>.*?)\s*\]`` in the commit message of the HEAD commit. However,
often we want to test changes locally without committing.  When running
locally for testing, you can add the same special text to a temporary
environment variable ``LINT_SKIP``. The same example above could be tested
locally like this without having to make a commit::

    LINT_SKIP="[lint skip uses_setuptools for recipes/mypackage]" circleci build

Skipping persistently on a per-recipe basis
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Sometimes a recipe will always fail linting. For example, in rare cases the
source for a recipe may only be available as a `git_url` or may require
`setuptools` as a runtime dependency. In these cases, add an `extra:
skip-lints` list to the ``meta.yaml`` indicating which lints should be
skipped, for example::

    extra:
      skip-lints:
        - uses_git_url
        - uses_setuptools

Linting functions
-----------------

`in_other_channels`
~~~~~~~~~~~~~~~~~~
Reason for failing: The package exists in another dependent channel (currently
conda-forge and defaults). This often happens when a general-use package
was added to bioconda first but was subsequently added to one of the more
general channels. In this case we'd prefer it to be in the general channel.

Rationale: We want to minimize duplicated work. If a package already exists in
another dependent channel, it doesn't need to be maintained in the bioconda
channel.

How to resolve: In special cases this can be overridden, for example if
a bioconda-specific patch is required. However it is almost always better to
fix or update the recipe in the other channel. Note that the package in the
bioconda channel will remain in order to maintain reproducibility.

`already_in_bioconda` (currently disabled)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Reason for failing: The current package version, build, and platform
(linux/osx) already exists in the bioconda channel.

Rationale: This acts as an early warning to bump version or build numbers.

How to resolve: Increase the version number or `build number
<https://conda.io/docs/building/meta-yaml.html#build-number-and-string>`_ as
appropriate.

`missing_home`
~~~~~~~~~~~~~~
Reason for failing: No homepage URL.

Rationale: We want to make sure users can get additional information about
a package, and it saves a separate search for the tool. Furthermore some tools
with name collisions have to be renamed to fit into the conda channel and the
homepage is an unambiguous original source.

How to resolve: Add the url in the `about section
<https://conda.io/docs/building/meta-yaml.html#about-section>`_.

`missing_summary`
~~~~~~~~~~~~~~~~~
Reason for failing: Missing a summary.

Rationale: We want to provide a minimal amount of information about the
package.

How to resolve: add a short descriptive summary in the `about
section <https://conda.io/docs/building/meta-yaml.html#about-section>`_.

`missing_license`
~~~~~~~~~~~~~~~~~
Reason for failing: No license provided.

Rationale: We need to ensure that adding the package to bioconda does not
violate the license

How to resolve: Add the license in the `about section
<https://conda.io/docs/building/meta-yaml.html#about-section>`_. There are some
ways of accommodating some licenses; see the GATK package for one method.

`missing_tests`
~~~~~~~~~~~~~~~
Reason for failing: No tests provided.

Rationale: We need at least minimal tests to ensure the programs can be found
on the path to catch basic installation errors.

How to resolve: Add basic tests to ensure the software gets installed; see
:ref:`tests` for more info.

`missing_hash`
~~~~~~~~~~~~~~
Reason for failing: Missing a hash in the source section.

Rationale: Hashes ensure that the source is downloaded correctly without being
corrupted.

How to resolve: Add a hash in the `source section
<https://conda.io/docs/building/meta-yaml.html#source-section>`_. See
:ref:`hashes` for more info.

`should_be_noarch` (currently disabled)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Reason for failing: The package should be labelled as ``noarch``.

Rationale: A ``noarch`` package should be created for pure Python packages, data packages, or
packages that do not require compilation. With this a single ``noarch`` package can be
used across multiple platforms and (in case of Python) Python versions, which saves
on build time and saves on storage space on the bioconda channel.

How to resolve: For pure Python packages, add ``noarch: python`` to the ``build`` section.
**Don't do this if your Python package has a command line interface**, as these are not
independent of the Python version!
For other generic packages (like a data package), add ``noarch: generic`` to the ``build`` section.
See `here <https://www.continuum.io/blog/developer-blog/condas-new-noarch-packages>`_ for
more details.

`should_not_be_noarch`
~~~~~~~~~~~~~~~~~~~~~~
Reason for failing: The package should **not** be labelled as ``noarch``.

Rationale: The package defines gcc as a dependency, or it contains a build/skip
section. In both cases, this means that there should be platform specific
versions of this package. This also holds for skipping Python versions, because
``noarch: python`` also implies that the resulting package will work with **all**
Python versions. This is typically not the case if you skip a Python version.

How to resolve: Remove the ``noarch`` statement.

`uses_git_url`
~~~~~~~~~~~~~~
Reason for failing: The source section uses a git URL.

Rationale: While this is supported by conda, we prefer
to not use this method since it is not always reproducible. Furthermore, the
Galaxy team mirrors each successfully built bioconda recipe. Mirroring git_urls
is problematic.

How to resolve: Use a direct URL. Ideally a github repo should have tagged
releases that are accessible as tarballs from the "releases" section of the
github repo.

`uses_perl_threaded`
~~~~~~~~~~~~~~~~~~~~
Reason for failing: The recipe has a dependency of ``perl-threaded``.

Rationale: Previously bioconda used ``perl-threaded`` as a dependency for Perl
packages, but now we are using ``perl`` instead. When one of these older recipes
is updated, it will fail this check.

How to resolve: Change ``perl-threaded`` to ``perl``.

`uses_javajdk`
~~~~~~~~~~~~~~
Reason for failing: The recipe has a dependency of ``java-jdk``.

Rationale: Previously bioconda used ``java-jdk`` as a dependency for Java
packages, but now we are using ``openjdk`` instead. When one of those older
recipes is updated, it will fail this check.

How to resolve: Change ``java-jdk`` to ``openjdk``.

`uses_setuptools` (currently disabled)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Reason for failing: The recipe has ``setuptools`` as a run dependency.

Rationale: ``setuptools`` is typically used to install dependencies for Python
packages but most of the time this is not needed within a conda package as
a run dependency.

How to resolve: Ensure that all dependencies are explicitly defined. Some
packages do need ``setuptools``, in which case this can be overridden.
``setuptools`` may be required, e.g., if a package loads resources via
``pkg_resources`` which is part of ``setuptools``. That dependency can also be
introduced implicitly when ``setuptools``-created console scripts are used.
To avoid this, make sure to carry ``console_scripts`` entry points from
``setup.py`` over to ``meta.yaml`` to replace them with scripts created by
``conda``/``conda-build`` which don't require ``pkg_resources``.

`has_windows_bat_file`
~~~~~~~~~~~~~~~~~~~~~~
Reason for failing: The recipe includes a ``.bat`` file.

Rationale: Often when using one of the skeleton commands (``conda skeleton
{cran,pypi,cpan}``), the command will include a Windows ``.bat`` file. Since
bioconda does not support Windows, any ``*.bat`` files are unused and to reduce
clutter we try to remove them.

How to resolve: Remove the ``.bat`` file from the recipe.

`setup_py_install_args`
~~~~~~~~~~~~~~~~~~~~~~~
Reason for failing: The recipe has ``setuptools`` as a build dependency, but
``build.sh`` needs to use certain arguments when running ``setup.py``.

Rationale: When a package depends on setuptools, we have to disable some parts
of setuptools during installation to make it work correctly with conda. In
particular, it seems that packages depend on other packages that specify entry
points (e.g., ``pyfaidx``) will cause errors about how ``setuptools`` is not
allowed to install ``certifi`` in a conda package.

How to resolve: Change the line in either in ``build.sh`` or the
``build:script`` key in ``meta.yaml`` from::

    $PYTHON setup.py install

to::

    $PYTHON setup.py install --single-version-externally-managed --record=record.txt

`invalid_identifiers`
~~~~~~~~~~~~~~~~~~~~~
Reason for failing: The recipes has an `extra -> identifiers` section with an
invalid format.

Rationale: The identifiers section has to be machine readable.

How to resolve: Ensure that the section is of the following format:

```
extra:
  identifiers:
    - doi:10.1093/bioinformatics/bts480
    - biotools:Snakemake
```

In particular, ensure that each identifier starts with a type
(`doi`, `biotools`, ...), followed by a colon and the identifier.
Whitespace is not allowed.


`*_not_pinned`
~~~~~~~~~~~~~~

Reason for failing: The recipe has dependencies that need to be pinned to
a specific version all across bioconda.

Rationale: Sometimes when a core dependency (like ``zlib``, which is used across
many recipes) is updated it breaks backwards compatibility. In order to avoid
this, for known-to-be-problematic dependencies we pin to a specific version
across all recipes.

How to resolve: Change the dependency line as follows. For each dependency
failing the linting, specify a jinja-templated version by converting it to
uppercase, prefixing it with ``CONDA_``, adding double braces, and adding a ``*``.

Examples are much easier to understand:

- ``zlib`` should become ``zlib {{ CONDA_ZLIB }}*``
- ``ncurses`` should become ``ncurses {{ CONDA_NCURSES }}*``
- ``htslib`` should become ``htslib {{ CONDA_HTSLIB }}*``
- ``boost`` should become ``boost {{ CONDA_BOOST }}*``
- ... and so on.

Here is an example in the context of a ``meta.yaml`` file where ``zlib`` needs to be
pinned:

.. code-block:: yaml

    # this will give a linting error because zlib is not pinned
    build:
      - zlib
    run:
      - zlib
      - bedtools

And here is the fixed version:

.. code-block:: yaml

    # fixed:
    build:
      - zlib {{ CONDA_ZLIB }}*
    run:
      - zlib {{ CONDA_ZLIB }}*
      - bedtools


Developer docs
--------------
For developers adding new linting functions:

Lint functions are defined in ``bioconda_utils.lint_functions``. Each function
accepts three arguments:

- `recipe`, the path to the recipe
- `meta`, the meta.yaml file parsed into a dictionary
- `df`, a dataframe channel info, typically as returned from
  `linting.channel_dataframe` and is expected to have the following columns:
  [build, build_number, name, version, license, platform, channel].

We need `recipe` because some lint functions check files (e.g.,
`has_windows_bat_file`). We need `meta` because even though we can parse it
from `recipe` within each lint function, it's faster if we parse the meta.yaml
once and pass it to many lint functions. We need `df` because we need channel
info to figure out if a version or build number needs to be bumped relative to
what's already in the channel.

If the linting test passes, the function should return None. Otherwise it
should return a dictionary. The keys in the dict will be propagated to columns
of a pandas DataFrame for downstream processing and so can be somewhat
arbitrary.

After adding a new linting function, add it to the
``bioconda_utils.lint_functions.registry`` tuple so that it gets used by
default.
