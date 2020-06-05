Linting
=======

In order to ensure high-quality packages, we now perform routine
checks on each recipe (called `linting
<http://stackoverflow.com/questions/8503559/what-is-linting>`_).

Linting is executed as a GitHub Check on all PRs and as a guarding
stage on all builds. It can also be executed locally using the
``bioconda-utils lint`` commeand.


Skipping a lint check
---------------------

The linter may occasionally create false positives. Lint checks can
therefore be disabled individually if there is good reason to do so.


Skipping persistently on a per-recipe basis
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Recipes may contain a section listing lint checks to be disabled::

  extra:
    skip-lints:
      - uses_setuptools  # uses pkg_resoures during run time

For example, `uses_setuptools` will trigger if a recipe
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


Lint Checks
-----------

Below, each lint check executed is shown and described. Lints are
grouped into a few sections, depending on what type of issue they aim
at preventing.

.. contents:: Index of all Lints Checks by Section:
   :local:


Incomplete Recipe
~~~~~~~~~~~~~~~~~

These are basic checks, making sure that the recipe is not missing
anything essential.

.. lint-check:: missing_home

   We want to make sure users can get additional information about a
   package, and it saves a separate search for the tool. Furthermore
   some tools with name collisions have to be renamed to fit into the
   conda channel and the homepage is an unambiguous original source.

.. lint-check:: missing_summary

   This is the "title" for the package. It will also be shown in
   package listings. Keep it brief and informative. One line does not
   mean one line on a landscape poster.

.. lint-check:: missing_license

   We need to ensure that adding the package to bioconda does not
   violate the license. No license means we have no permission to
   distribute the package, so we need to have one.

   If the license is not a standard FOSS license, please read it to
   make sure that we are actually permitted to distribute the
   software.

.. lint-check:: missing_tests

   In order to provide a collection of actually working tools, some
   basic testing is required. The tests should make sure the tool was
   built (if applicable) and installed correctly, and guard against
   things breaking with e.g. a version update.

   The tests can include commands to be run or modules to import. You
   can also use a script (``run_test.sh``, ``run_test.py`` or
   ``run_test.pl``) to execute tests (which must exit with exit status
   0).

   See :ref:`tests` for more information.

.. lint-check:: missing_hash

   The hash or checksum ensures the integrity of the downloaded source
   archive. It guards both against broken or incomplete downloads and
   against the source file's content changing unexpectedly.

   While conda allows ``md5``, ``sha1`` in addition to ``sha256``, we
   prefer the latter.

   See :ref:`hashes` for more info.

.. lint-check:: missing_version_or_name

   For obvious reasons, each package must at least have a name and a
   version.

.. lint-check:: empty_meta_yaml

   Intentionally left blank. Or not?

.. lint-check:: missing_meta_yaml

.. lint-check:: missing_build

.. lint-check:: missing_build_number

   The build number should be ``0`` for any new version and
   incremented with each revised build published.


Noarch or not noarch
~~~~~~~~~~~~~~~~~~~~

Not all packages are platform specific. Pure Python packages for
example will usually work on any platform without modification. For
this reason, we have a third "subdir" (in conda lingo) in addition to
``linux-64`` and ``osx-64`` called ``noarch``. Packages marked with
``noarch: True`` or ``noarch: python`` will be built only once and can
then be used on both supported target platforms.

There are some conda idiosyncracies to be aware of when marking a package
as noarch:

- A ``noarch`` package cannot use ``skip``. Packages that are
  ``noarch`` but require specific Python versions should use pinning
  (e.g. ``- python >3``).

- Packages that are not ``noarch`` must use ``skip`` and must not pin
  Python (it will simply not work as expected).

.. lint-check:: should_be_noarch_python

   Python packages that do not include compiled modules (e.g. Cython
   build modules) are architecture independent and only need to be
   built (packaged) once, saving time and space.


.. lint-check:: should_be_noarch_generic

   Packages that contain no platform specific binaries, e.g. Java
   packages, and are not Python packages, should be marked as
   ``noarch: generic``. This saves build time and space on our
   hosters.

.. lint-check:: should_not_be_noarch_compiler

   Packages containing platform specific binaries should not be
   marked ``noarch``. Use of a compiler was detected, which
   generally indicates that platform specific binaries were built.

.. lint-check:: should_not_be_noarch_source

   Packages downloading different sources for each platform cannot be
   marked ``noarch``.

.. lint-check:: should_not_be_noarch_skip

.. lint-check:: should_not_use_skip_python

   The ``skip`` mechanism works by not creating packages for some of
   our target platforms and interpreters (= Python versions). It
   therefore does not work in conjunction with ``noarch``.

   If the recipe has a ``skip`` only for specific Python versions
   (e.g. ``skip: True # [py2k]``), use pinning instead::

     requirements:
       run:
         python >3


Policy
~~~~~~

These checks enforce some of our "policy" decisions for keeping
Bioconda and it's recipe repository consistent and clean.


.. lint-check:: uses_vcs_url

   While ``conda`` technically supports downloading sources directly
   from a versioning system, we strongly discourage doing so.

   There are a number of reasons for this:

   - Making a release expresses an author's intent that the software
     is at a stable point suitable for distribution. Distributing a
     specific, unreleased revision makes it unnecessarily difficult
     for upstream authors to help with bugs users might encounter.
   - For reproducibility, we keep a backup of all source files used to
     build packages on Bioconda, but cannot (currently) do so for
     git/svn/hg repositories.
   - Git uses checksums (hashes) as revision labels. These have no
     implicit order, and would require assigning a pseudo version
     number to the package to allow knowing whether another release is
     newer or older than a git revision based one.

   With the exception of old, orphaned projects, upstream authors will
   usually be happy to create a release if asked kindly. Most hosting
   sites allow "tagging" a release via their web interface, making the
   process simple.

.. lint-check:: folder_and_package_name_must_match

   It's just way simpler to find the "recipe" building a "package" if
   you can expect that the recipe building "samtools" is found in the
   "samtools" folder (and not hiding in "new_release" or "bamtools").

   If you are using ``outputs`` to split a single upstream
   distribution into multiple packages, try to make sure each output
   package name contains the name of the tool you are packaging

.. lint-check:: gpl_requires_license_distributed

   While many upstream authors are not aware of this when they grant
   license to use and distribute their work under the GPL, the GPL
   says that we must include a copy of the GPL with every package we
   distribute. It can be annoying and feel redundant, but it simply is
   what we must do to be permitted to distribute the software.

.. lint-check:: should_not_use_fn

   The ``fn`` is really only needed if you have multiple ``url`` s that
   share a filename, which is a somewhat constructed scenario.

.. lint-check:: has_windows_bat_file

   The skeleton commands (e.g. ``conda skeleton pypi``) create this
   file automatically, but we do not build for windows, making this
   file merely clutter needlessly increasing the size of our git
   repository.

.. lint-check:: long_summary

   Recipes have a ``summary`` and ``description`` field. The
   recipe/package description pages at anaconda.org/bioconda and here
   are designed to use the ``summary`` as a title line and provide a
   separate section for multi-paragraph descriptions filled with
   content from the ``description`` field. The ``summary`` is also
   used for package listings with only one row per package.

   It just looks better if the summary fits into one line.

.. lint-check:: cran_packages_to_conda_forge

   Conda-Forge has a very active R community planning to eventually
   package all of CRAN. For that reason, we only allow CRAN packages
   on Bioconda if they depend on other Bioconda packages.


Syntax
~~~~~~

These checks ensure that the ``extra`` section conforms to our
"schema".

.. lint-check:: extra_identifiers_not_list

.. lint-check:: extra_identifiers_not_string

.. lint-check:: extra_identifiers_missing_colon

   Ensure that the section is of the following format::

     extra:
       identifiers:
         - doi:10.1093/bioinformatics/bts480
         - biotools:Snakemake

   In particular, ensure that each identifier starts with a type
   (``doi``, ``biotools``, ...), followed by a colon and the
   identifier.  Whitespace is not allowed.

.. lint-check:: extra_skip_lints_not_list

   The recipe is trying to skip a lint with an unknown name. Check
   the list here for the correct name.


Recipe Parsing
~~~~~~~~~~~~~~

These lints happen implicitly during recipe parsing. They cannot be
skipped!

.. lint-check:: duplicate_key_in_meta_yaml

   Say you have two ``requirements: build:`` sections, should the
   second replace the list in the first, or should it append to it?
   The YAML standard does not specify this. Instead, it just says that
   sections cannot occur twice. Some YAML parsers allow duplicate
   keys, but it's often unclear what the result should be, and it's
   easy to miss another section further down in the recipe, so we
   don't.

.. lint-check:: unknown_selector

   The recipe uses an ``# [abc]`` selector that is not understood by
   bioconda-utils. If you actually do encounter this, ping
   ``@bioconda/core`` at it is very likely a bug.

.. lint-check:: conda_render_failure

   There was an error in ``conda-build`` "rendering" the
   recipe. Please contact ``@bioconda/core`` for help.

.. lint-check:: jinja_render_failure

   Conda recipes are technically not YAML, but Jinja YAML
   templates. The Jinja template engine turning the recipe text into
   YAML complained about a part in your recipe.

   Most frequently, this is due to unbalanced or missing braces,
   parentheses or quotes.

.. lint-check:: unknown_check

   You broke it!!! Congratulations, you found a bug in the
   linter. Ping @bioconda/core to figure out what's going on.

Repository
~~~~~~~~~~

.. lint-check:: in_other_channels

   The package exists in another dependent channel (currently
   conda-forge and defaults). This often happens when a general-use
   package was added to bioconda first but was subsequently added to
   one of the more general channels. In this case we'd prefer it to be
   in the general channel.

   We want to minimize duplicated work. If a package already exists in
   another dependent channel, it doesn't need to be maintained in the
   bioconda channel.

   In special cases this can be overridden, for example if a
   bioconda-specific patch is required. However it is almost always
   better to fix or update the recipe in the other channel. Note that
   the package in the bioconda channel will remain in order to
   maintain reproducibility.

   Sometimes when adding or updating a recipe in a pull request to
   ``conda-forge`` the conda-forge linter will warn that a recipe with
   the same name already exists in bioconda. When this happens,
   usually the best thing to do is:

   1. Submit -- but don't merge yet! -- a PR to bioconda that removes the
      recipe.  In that PR, reference the conda-forge/staged-recipes PR.
   2. Merge the conda-forge PR adding or updating the recipe
   3. Merge the bioconda PR deleting the recipe


.. lint-check:: build_number_needs_bump

   Every time you change a recipe, you should assign a new
   (incremented) build number. Otherwise, the package may not be built
   (it will be built only if the "build string" is different, which
   might happen only on one architecture and not the other).

.. lint-check:: build_number_needs_reset

   If no previous build exists for a package/version combination, the
   build number should be 0.

.. lint-check:: recipe_is_blacklisted

   We maintain a list of packages that are "blacklisted". Recipes are
   added to this list if they fail to rebuild and would block
   automatic build processes. Just remove your package from this list
   and proceed as normal. Hopefully, you can fix whatever got the
   recipe on the blacklist!

Deprecations
~~~~~~~~~~~~

These checks catch packages or recipe idioms we no longer use or that
no longer work and need to be changed.

.. lint-check:: uses_perl_threaded

   Previously, Bioconda used ``perl-threaded`` as a dependency for
   Perl packages, but now we are using ``perl`` instead. When one of
   these older recipes is updated, it will fail this check.

.. lint-check:: uses_javajdk

   Previously, Bioconda used ``java-jdk`` as a dependency for Java
   packages, but now we are using ``openjdk`` instead. When one of
   those older recipes is updated, it will fail this check.

.. lint-check:: deprecated_numpy_spec

   Originally, ``conda`` used the ``numpy x.x`` syntax to enable
   pinning for numpy. This way of pinning has been superceded by the
   ``conda_build_config.yaml`` way of automatic pinning. You can
   now just write ``numpy`` (without any special string appended).

.. lint-check:: uses_matplotlib

   The ``matplotlib`` package has been split into ``matplotlib``
   and ``matplotlib-base``. The only difference is that
   ``matplotlib`` contains an additional dependency on ``pyqt``,
   which pulls in many other dependencies. In most cases, using
   ``matplotlib-base`` is sufficient.

Build helpers
~~~~~~~~~~~~~

.. lint-check:: should_use_compilers

   The recipe uses a compiler directly. Since version 3,
   ``conda-build`` has a special syntax for compilers, e.g.::

     build:
       - {{ compiler('cxx') }}

   This will select the appropriate C++ compiler (``clang`` on MacOS
   and ``g++`` on Linux) automatically, inject apropriate environment
   variables (``CXX``, ``CXXFLAGS``, ``LDFLAGS``, ...) into the build
   environment and create the right dependencies (e.g. ``libgcc``).
   Which compilers are used is configured via
   ``conda_build_config.yaml``, which we "inherit" from conda-forge.

   Packages no longer needed are ``toolchain``, ``libgfortran``,
   ``libgcc``. The compilers ``gcc``, ``llvm``, ``go``, and ``cgo``
   don't need to be installed directly, instead specify ``c``,
   ``cxx``, ``fortran``, ``go`` or ``cgo`` as language using the
   compiler syntax.

   One exception from this is ``llvm-openmp # [osx]`` which still
   needs to be added manually if your package makes use of OpenMP.

   See :ref:`compiler-tools` for details.

.. lint-check:: uses_setuptools

   ``setuptools`` is typically used to install dependencies for Python
   packages but most of the time this is not needed within a conda
   package as a run dependency.

   Some packages do need ``setuptools``, in which case this check can
   be overridden.  ``setuptools`` may be required, e.g., if a package
   loads resources via ``pkg_resources`` which is part of
   ``setuptools``. That dependency can also be introduced implicitly
   when ``setuptools``-created console scripts are used.  To avoid
   this, make sure to carry ``console_scripts`` entry points from
   ``setup.py`` over to ``meta.yaml`` to replace them with scripts
   created by ``conda``/``conda-build`` which don't require
   ``pkg_resources``. Recipes generated via ``conda skeleton pypi``
   already include the required section.


.. lint-check:: setup_py_install_args

   When a package depends on setuptools, we have to disable some parts
   of setuptools during installation to make it work correctly with
   conda. In particular, it seems that packages depend on other
   packages that specify entry points (e.g., ``pyfaidx``) will cause
   errors about how ``setuptools`` is not allowed to install
   ``certifi`` in a conda package.

   Change the line in either in ``build.sh`` or the ``build:script``
   key in ``meta.yaml`` from::

     $PYTHON setup.py install

   to::

     $PYTHON setup.py install --single-version-externally-managed --record=record.txt


.. lint-check:: compilers_must_be_in_build

   A ``{{ compiler('xyz') }}`` variable was found, but not in the
   ``build:`` section. Move ``{{ compiler() }}`` variables to the
   ``build:`` section.

.. lint-check:: cython_must_be_in_host

   Cython should match the Python version, so we keep it in the
   host section for now.

.. lint-check:: cython_needs_compiler

   Cython is compiled into C code, which then needs to be
   compiled. You almost certainly want to have a C compiler in your
   recipe.


Linter Errors
~~~~~~~~~~~~~

.. lint-check:: linter_failure


Developer docs
--------------

See `bioconda_utils.lint` for information on how to write additional checks.

