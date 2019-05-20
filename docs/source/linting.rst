Linting
=======

In order to ensure high-quality packages, we now perform routine checks on each
recipe (called `linting
<http://stackoverflow.com/questions/8503559/what-is-linting>`_).

Linting is executed as a GitHub Check on all PRs and as a guarding stage on
all builds. It can also be executed locally using the ``bioconda-utils lint``
commeand.


Skipping a lint check
---------------------

The linter may occasionally create false positives. Lint checks can therefore
be disabled individually if there is good reason to do so.



Skipping persistently on a per-recipe basis
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Recipes may contain a section listing lint checks to be disabled::

  extra:
    skip-lints:
      - uses_setuptools  # uses pkg_resoures during run time

For example, :ref:`linting:uses_setuptools` will trigger if a recipe
requires ``setuptools`` in its ``run`` section. While the vast
majority of tools only need ``setuptools`` during installation, there
are some exceptions to this rule. A tool accessing the
``pkg_resources`` module which is part of setuptools actually does
need ``setuptools`` present during run time. In this case, add skip as
shown above and add a comment describing why the recipe needs to
ignore that particular lint check.


Skipping on a per-commit basis
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

While only recommended in very special cases, it is possible to skip
specific linting tests on a commit by using special text in the commit
message, ``[lint skip $FUNCTION for $RECIPE]`` where ``$FUNCTION`` is
the name of the function to skip and ``$RECIPE`` is the path to the
recipe directory for which this test should be skipped.

For example, if the linter reports a ``uses_setuptools`` issue for
``recipes/mypackage``, but you are certain the package really needs
setuptools, you can add ``[lint skip uses_setuptools for
recipes/mypackage]`` to the commit message and this linting test will
be skipped on CircleCI.  Multiple tests can be skipped by adding
additional special text. For example, ``[lint skip uses_setuptools for
recipes/pkg1] [lint skip in_other_channels for
recipes/pkg2/0.3.5]``. Note in the latter case that the second recipe
has a subdirectory for an older version.

Technically we check for the regular expression ``\[\s*lint skip
(?P<func>\w+) for (?P<recipe>.*?)\s*\]`` in the commit message of the
HEAD commit. However, often we want to test changes locally without
committing.  When running locally for testing, you can add the same
special text to a temporary environment variable
:envvar:`LINT_SKIP`. The same example above could be tested locally
like this without having to make a commit::

    LINT_SKIP="[lint skip uses_setuptools for recipes/mypackage]" circleci build


.. _in-conda-forge:

Recipes duplicated in conda-forge
---------------------------------

Sometimes when adding or updating a recipe in a pull request to
``conda-forge`` the conda-forge linter will warn that a recipe with
the same name already exists in bioconda. When this happens, usually
the best thing to do is:

1. Submit -- but don't merge yet! -- a PR to bioconda that removes the
   recipe.  In that PR, reference the conda-forge/staged-recipes PR.
2. Merge the conda-forge PR adding or updating the recipe
3. Merge the bioconda PR deleting the recipe


Description of Lint Checks
--------------------------

.. lint-check:: in_other_channels

   Reason for failing: The package exists in another dependent channel
   (currently conda-forge and defaults). This often happens when a
   general-use package was added to bioconda first but was
   subsequently added to one of the more general channels. In this
   case we'd prefer it to be in the general channel.

   Rationale: We want to minimize duplicated work. If a package
   already exists in another dependent channel, it doesn't need to be
   maintained in the bioconda channel.

   How to resolve: In special cases this can be overridden, for
   example if a bioconda-specific patch is required. However it is
   almost always better to fix or update the recipe in the other
   channel. Note that the package in the bioconda channel will remain
   in order to maintain reproducibility.


.. lint-check:: build_number_needs_bump

   Reason for failing: The current package version, build, and
   platform (linux/osx) already exists in the bioconda channel.

   Rationale: This change does not trigger the build of any packages,
   leading to a mismatch between the recipe and our package archive.

   How to resolve: Increase the version number or `build number
   <https://conda.io/docs/building/meta-yaml.html#build-number-and-string>`_
   as appropriate.


.. lint-check:: missing_home

   Reason for failing: No homepage URL.

   Rationale: We want to make sure users can get additional
   information about a package, and it saves a separate search for the
   tool. Furthermore some tools with name collisions have to be
   renamed to fit into the conda channel and the homepage is an
   unambiguous original source.

   How to resolve: Add the url in the `about section
   <https://conda.io/docs/building/meta-yaml.html#about-section>`_.


.. lint-check:: missing_summary

   Reason for failing: Missing a summary.

   Rationale: We want to provide a minimal amount of information about
   the package.

   How to resolve: add a short descriptive summary in the `about
   section
   <https://conda.io/docs/building/meta-yaml.html#about-section>`_.


.. lint-check:: missing_license

   Reason for failing: No license provided.

   Rationale: We need to ensure that adding the package to bioconda
   does not violate the license

   How to resolve: Add the license in the `about section
   <https://conda.io/docs/building/meta-yaml.html#about-section>`_. There
   are some ways of accommodating some licenses; see the GATK package
   for one method.


.. lint-check:: missing_tests

   Reason for failing: No tests provided.

   Rationale: We need at least minimal tests to ensure the programs
   can be found on the path to catch basic installation errors.

   How to resolve: Add basic tests to ensure the software gets
   installed; see :ref:`tests` for more info.


.. lint-check:: missing_hash

   Reason for failing: Missing a hash in the source section.

   Rationale: Hashes ensure that the source is downloaded correctly
   without being corrupted.

   How to resolve: Add a hash in the `source section
   <https://conda.io/docs/building/meta-yaml.html#source-section>`_. See
   :ref:`hashes` for more info.


.. lint-check:: should_be_noarch

   Reason for failing: The package should be labelled as ``noarch``.

   Rationale: A ``noarch`` package should be created for pure Python
   packages, data packages, or packages that do not require
   compilation. With this a single ``noarch`` package can be used
   across multiple platforms and (in case of Python) Python versions,
   which saves on build time and saves on storage space on the
   bioconda channel.

   How to resolve: For pure Python packages, add ``noarch: python`` to
   the ``build`` section.  **Don't do this if your Python package has
   a command line interface**, as these are not independent of the
   Python version!  For other generic packages (like a data package),
   add ``noarch: generic`` to the ``build`` section.  See `here
   <https://www.continuum.io/blog/developer-blog/condas-new-noarch-packages>`_
   for more details.


.. lint-check:: should_not_be_noarch_compiler

   Reason for failing: The package should **not** be labelled as
   ``noarch``.

   Rationale: The package defines gcc as a dependency, or it contains
   a build/skip section. In both cases, this means that there should
   be platform specific versions of this package. This also holds for
   skipping Python versions, because ``noarch: python`` also implies
   that the resulting package will work with **all** Python
   versions. This is typically not the case if you skip a Python
   version.

   How to resolve: Remove the ``noarch`` statement.


.. lint-check:: uses_git_url

   Reason for failing: The source section uses a git URL.

   Rationale: While this is supported by conda, we prefer to not use
   this method since it is not always reproducible. Furthermore, the
   Galaxy team mirrors each successfully built bioconda
   recipe. Mirroring git_urls is problematic.

   How to resolve: Use a direct URL. Ideally a github repo should have
   tagged releases that are accessible as tarballs from the "releases"
   section of the github repo.


.. lint-check:: uses_perl_threaded

   Reason for failing: The recipe has a dependency of
   ``perl-threaded``.

   Rationale: Previously bioconda used ``perl-threaded`` as a
   dependency for Perl packages, but now we are using ``perl``
   instead. When one of these older recipes is updated, it will fail
   this check.

   How to resolve: Change ``perl-threaded`` to ``perl``.


.. lint-check:: uses_javajdk

   Reason for failing: The recipe has a dependency of ``java-jdk``.

   Rationale: Previously bioconda used ``java-jdk`` as a dependency
   for Java packages, but now we are using ``openjdk`` instead. When
   one of those older recipes is updated, it will fail this check.

   How to resolve: Change ``java-jdk`` to ``openjdk``.


.. lint-check:: uses_setuptools

   Reason for failing: The recipe has ``setuptools`` as a run
   dependency.

   Rationale: ``setuptools`` is typically used to install dependencies
   for Python packages but most of the time this is not needed within
   a conda package as a run dependency.

   How to resolve: Ensure that all dependencies are explicitly
   defined. Some packages do need ``setuptools``, in which case this
   can be overridden.  ``setuptools`` may be required, e.g., if a
   package loads resources via ``pkg_resources`` which is part of
   ``setuptools``. That dependency can also be introduced implicitly
   when ``setuptools``-created console scripts are used.  To avoid
   this, make sure to carry ``console_scripts`` entry points from
   ``setup.py`` over to ``meta.yaml`` to replace them with scripts
   created by ``conda``/``conda-build`` which don't require
   ``pkg_resources``.


.. lint-check:: has_windows_bat_file

   Reason for failing: The recipe includes a ``.bat`` file.

   Rationale: Often when using one of the skeleton commands (``conda
   skeleton {cran,pypi,cpan}``), the command will include a Windows
   ``.bat`` file. Since bioconda does not support Windows, any
   ``*.bat`` files are unused and to reduce clutter we try to remove
   them.

   How to resolve: Remove the ``.bat`` file from the recipe.


.. lint-check:: setup_py_install_args

   Reason for failing: The recipe has ``setuptools`` as a build
   dependency, but ``build.sh`` needs to use certain arguments when
   running ``setup.py``.

   Rationale: When a package depends on setuptools, we have to disable
   some parts of setuptools during installation to make it work
   correctly with conda. In particular, it seems that packages depend
   on other packages that specify entry points (e.g., ``pyfaidx``)
   will cause errors about how ``setuptools`` is not allowed to
   install ``certifi`` in a conda package.

   How to resolve: Change the line in either in ``build.sh`` or the
   ``build:script`` key in ``meta.yaml`` from::

     $PYTHON setup.py install

   to::

     $PYTHON setup.py install --single-version-externally-managed --record=record.txt


.. lint-check:: extra_identifiers_not_list

.. lint-check:: extra_identifiers_not_string

.. lint-check:: extra_identifiers_missing_colon

   Reason for failing: The recipe has an ``extra -> identifiers``
   section with an invalid format.

   Rationale: The identifiers section has to be machine readable.

   How to resolve: Ensure that the section is of the following
   format::

     extra:
       identifiers:
         - doi:10.1093/bioinformatics/bts480
         - biotools:Snakemake

   In particular, ensure that each identifier starts with a type
   (``doi``, ``biotools``, ...), followed by a colon and the
   identifier.  Whitespace is not allowed.


.. lint-check:: deprecated_numpy_spec

   Reason for failing: The recipe contains ``numpy x.x`` in build or
   run requirements.

   Rationale: This kind of version pinning is deprecated, and numpy
   pinning is now handled automatically by the system.

   How to resolve: Remove the ``x.x``.


.. lint-check:: should_not_use_fn

   Reason for failing: Recipe contains a ``fn:`` key in the
   ``source:`` section

   Rationale: Conda-build 3 no longer requres ``fn:``, and it is
   redundant with ``url:``.

   How to resolve: Remove the ``source: fn:`` key.


.. lint-check:: should_use_compilers

   Reason for failing: The recipe has one of ``gcc``, ``llvm``,
   ``libgfortran``, or ``libgcc`` as dependencies.

   Rationale: Conda-build 3 now uses compiler tools, which are more
   up-to-date and better-supported.

   How to resolve: Use ``{{ compiler() }}`` variables. See
   :ref:`compiler-tools` for details.


.. lint-check:: compilers_must_be_in_build

   Reason for failing: A ``{{ compiler() }}`` varaiable was found, but
   not in the ``build:`` section.

   Rational: The compiler tools must not be in ``host:`` or ``run:``
   sections.

   How to resolve: Move ``{{ compiler() }}`` variables to the
   ``build:`` section.


Developer docs
--------------

See `bioconda_utils.lint` for information on how to write additional checks.

