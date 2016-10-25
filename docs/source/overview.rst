Overview
========

Conda overview
--------------
The `conda` package manager streamlines software installation. It is
functionally equivalent to PyPI, apt, homebrew, CRAN, and CPAN -- combined.
`conda` packages are hosted on anaconda.org, and packages can be installed
using the command ``conda install packagename``. ContinuumIO makes available
many standard packages, but for more custom applications, `conda` uses
"channels" as a mechanism of hosting user-contributed packages.  By adding one
or more channels either to the install command or to their local configuration,
a user can take advantage of packages prepared by more specialized package
maintainers.

Bioconda overview
-----------------
The `bioconda` channel contains bioinformatics software packages. This includes
aligners (e.g., STAR, bwa), R/Bioconductor packages (e.g., DESeq2, edgeR),
other utilities (e.g., FastQC, bedtools, bedops), and even entire workflows
(e.g., bcbio-rnaseq). There are currently over 1500 bioinformatics-related
packages in the bioconda channel.

Reproducibility and compatibility are two major goals of `bioconda`. The easy
way to do things would be to build packages on our local machine and upload
them to anaconda.org. However, this is unlikely to be compatible with many
machines, since the local machine may have different versions of compilers or
system-wide libraries.

Instead, we build packages in an automated fashion using a Docker container
representing the lowest common denominator of systems supported. Building is
performed in an automated fashion on Travis-CI.

The role of bioconda-utils
==========================
``bioconda-utils`` is a set of tools for working with and managing ``bioconda``
recipes. It is used by the Travis-CI setup to build, test, and upload packages.
For example it has tools to:

* create skeleton recipes for various supported languages and repositories
* "lint" recipes to check formatting and recipe contends according to  bionconda standards
* build one recipe or many recipes, either locally or in an isolated docker container
* optionally export a package built in a docker container to the local system's
  conda-build directory for local use
* test built packages in a minimal container using ``mulled-build``
* recursively identify dependencies across recipes
* build a DAG for visualization

Problems and how bioconda-utils solves them
-------------------------------------------
Compatibility with system libraries
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Take the example of a `conda` package for a C program that is compiled with
`gcc` and needs `libgcc` to run. This package can be successfully built without
specifying `gcc` and `libgcc` in the recipe as long as the machine has them
installed locally. However, when that package is installed via `conda` to
another machine lacking `libgcc` (for example, a minimal Docker container),
running the package will fail.

Furthermore, if a package is built on a machine with a recent version of
`libgcc`, it may not run on a machine with older `libgcc`. Since `gcc` is
largely backwards-compatible, building with an older version of `gcc` is
preferable because it can be run on systems with older versions as well.

This package, `bioconda-utils`, solves this compatibility problem by building
packages in a Docker container that is purposefully missing most system
libraries. If a dependency is not explicitly specified in the recipe, the
recipe will fail to build. A `bioconda` package that needs `libgcc` to run must
specify `libgcc` in the run dependencies. We try to use the oldest version of
`libgcc` that is practical in order to maximize compatibility.

Long wait times when testing recipes
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Travis-CI is a great resource for building and testing packages. However there
is a limit to the number of simultaneous builds. With many contributors, it can
take a while (i.e. hours) for builds to complete. To avoid wasting time on
failed travis-ci builds, it is important to make sure a package builds
successfully on a local machine before submitting a pull request to be built on
travis-ci.

`bioconda-utils` solves this by providing tools for building locally using the
same infrastructure as that used on travis-ci. We cannot yet support testing
OSX packages on Linux, but if you have a Mac then you can test Linux (via
Docker) and OSX (using locally-installed conda-build) packages before
submitting to travis-ci.

Testing in minimal containers
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
The act of building a `conda` package may require more system libraries to be
installed than running the package itself. For example, building a `conda`
package for a simple C program requires Python to be installed in order to run
`conda-build` itself. While `conda` does perform post-build tests, these tests
are still done on the same system and therefore may not catch errors that would
pop up when running the same package on a minimal (e.g., busybox) Docker
container.

`bioconda-utils` solves this by testing built packages in a busybox container,
using `mulled-build` and `involucro`. This helps ensure all dependencies are
explicitly specified in the recipe.

An added bonus of this testing is that once we have the minimal container with
the recipe installed in it, we can upload the container itself. That is, every
successful `bioconda-utils`-built package also gets a matching Docker container.

Lifecycle of a bioconda recipe
------------------------------
To make a new package available in the `bioconda` channel, a recipe for the
package needs to be merged in to the master branch of the `bioconda-recipes`
repository. The build system takes care of tests and uploading to the channel;
it's up to the contributor to write the recipe and make sure it passes tests.

In practice, the process goes something like this:

* Contributor wants to add a new package
* Contributer clones the `bioconda-recipes` repo and creates a new branch
* Contributor creates a new recipe in the ``recipes`` directory, and tests locally
* Contributor opens a pull request (PR) on the `bioconda-recipes` github repo
* The PR page indicates that tests need to be passed first
* Travis-CI is automatically notified by github of the PR, and pulls the PR for testing
* Travis-CI tests the PR and automatically notifies github of the test status
* Contributor makes changes as appropriate to get the tests to pass, and
  first-time contributors should get approval of their PR by @bioconda/core/
* When tests pass, the PR can be merged into master by clicking the green button in the PR
* Travis-CI is again notified, and starts testing the master branch
* When tests pass on the master branch, Travis-CI automatically uploads the
  package to the `bioconda` channel on anaconda.org
* Documentation is re-built and uploaded to bioconda.github.io
* The package can now be installed anywhere with ``conda install packagename -c bioconda``

