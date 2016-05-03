# The bioconda channel

[![Travis builds](https://img.shields.io/travis/bioconda/bioconda-recipes/master.svg?style=flat-square&label=builds)](https://travis-ci.org/bioconda/bioconda-recipes)
[![Travis tests](https://img.shields.io/travis/bioconda/bioconda-tests/master.svg?style=flat-square&label=tests)](https://travis-ci.org/bioconda/bioconda-tests)

[Conda](http://anaconda.org) is a platform- and language-independent package
manager that sports easy distribution, installation and version management of
software.  The [bioconda channel](https://anaconda.org/bioconda) is a Conda
channel providing bioinformatics related packages.  This repository hosts the
corresponding recipes.

## User guide

Please visit https://bioconda.github.io for details.

## Developer guide

If you want to contribute new packages to Bioconda, you are invited to join the
Bioconda team.  Please post in the [team thread on
GitHub](https://github.com/bioconda/recipes/issues/1) to ask for permission.

We build Linux packages inside a CentOS 5 docker container to maintain
compatibility across multiple systems. OSX packages are built using the [OSX
build environment](https://docs.travis-ci.com/user/osx-ci-environment/) on
[Travis CI](https://travis-ci.org/).

The steps below describe how to contribute a new package. The following
prerequisites are assumed:

- The [`conda`](http://anaconda.org) command line tool. This comes with the
  full [Anaconda scientific Python stack](https://www.continuum.io/downloads)
  installation, or the slimmed-down
  [Miniconda](http://conda.pydata.org/miniconda.html). The Python 3 version is
  recommended.
- [`docker`](https://www.docker.com/)
- [`git`](https://git-scm.com/)

### Step 1: Create a new recipe

Fork this repository or create a new branch to work in. Within the new branch,
[create a recipe](http://conda.pydata.org/docs/building/build.html)
(`your_package` in this example) in the `recipes` directory. See our [guidelines](GUIDELINES.md) for best practices and examples.

### Step 2: Test the recipe

When the recipe is ready, first test it with your local conda installation via

    conda build recipes/your_package

If the recipe has dependencies in the bioconda channel (this is often the
case), you will need to add `--channel bioconda` to the command. If the recipe
is an R package, you will also need to add `--channel r`. For example many
Bioconductor packages will be built using:

    conda build recipes/your_package --channel bioconda --channel r

Then, you can test it in the docker container with:

    docker run -v `pwd`:/bioconda-recipes bioconda/bioconda-builder --packages your_package --env-matrix /bioconda-recipes/scripts/env_matrix.yml

To optionally build for a specific Python version, provide the `CONDA_PY`
environmental variable. For example, to build specifically for Python 3.4:

    docker run -e CONDA_PY=34 -v `pwd`:/bioconda-recipes bioconda/bioconda-builder --packages your_package --env-matrix /bioconda-recipes/scripts/env_matrix.yml

To optionally build and test all packages (if they don't already exist), leave off the
package name:

    docker run -v `pwd`:/tmp/conda-recipes bioconda/bioconda-builder --env-matrix /bioconda-recipes/scripts/env_matrix.yml

If rebuilding a previously-built package and the version number hasn't changed,
be sure to increment the build number in `meta.yaml` (the default build number
is 0):

    build:
      number: 1

See below for building on OSX.

### Step 3: Submit a pull request

Once these local tests pass, submit a [pull
request](https://help.github.com/articles/using-pull-requests) to this
repository. The [travis-ci](https://travis-ci.org) continuous
integration service will automatically test the pull request.

When the PR tests pass, the PR can be merged into the master branch.

Travis-CI will again run tests. However, when testing the master branch, new,
successfully-built packages will be uploaded to the `bioconda` conda channel.
Once these tests pass, your new package can now be installed from anywhere
using:

    conda install -c bioconda your_package

### Step 4:

If you want to promote the Bioconda installation of your package, we recommend
to add the following badge to your homepage:

```
[![bioconda-badge](https://img.shields.io/badge/install%20with-bioconda-brightgreen.svg?style=flat-square)](http://bioconda.github.io)
```

This will display as
[![bioconda-badge](https://img.shields.io/badge/install%20with-bioconda-brightgreen.svg?style=flat-square)](https://bioconda.github.io).
For other styles, replace ``?style=flat-square`` with ``?style=flat`` or
``?style=plastic``.

### Building packages for Mac OSX
**By default, recipes will be built for both Linux and OSX**
(see "The bioconda build system" section below) upon submitting
a pull request. Many recipes build cleanly on Linux but not on OSX. The easy
fix is to explicitly skip the OSX build using a [platform-specific
selector](http://conda.pydata.org/docs/building/meta-yaml.html#skipping-builds)
on a line in the `meta.yaml` that skips the build, like this:

```
build:
  skip: True  # [osx]
```

A better fix is to figure out what needs to be changed for a build to work on
OSX, and include those changes using platform-specific selectors. Such changes
could include tweaks to the build script, applying patches, or using
OS-specific installation methods. See [graphviz](recipes/graphviz),
[blast](recipes/blast), and UCSC utils like
[ucsc-pslcdnafilter](recipes/ucsc-pslcdnafilter) for examples of these methods.

To set up a local OSX machine for building and testing OSX recipes, run
``scripts/travis-setup.sh``. Several commands in this script will prompt for
sudo privileges, but the script itself should be run as a regular user. This
script will set up a conda environment in ``/anaconda`` and install necessary
prerequisites.

To test all OSX recipes (skipping those that define `skip: True #[osx]`) use
the following from the top-level dir:

```bash
scripts/build-packages.py --repository . --env-matrix scripts/env_matrix.yml
```

### Managing multiple versions of a package

If there is interest to keep multiple versions of a package or to explicitly
build an older version of a package, you can store those versions in
subdirectories of the corresponding recipe, e.g.:

```
java-jdk/
├── 7.0.91
│   ├── build.sh
│   └── meta.yaml
├── build.sh
└── meta.yaml
```

There should always be a primary in the root directory of a package that is
updated when new releases are made.

### Other notes

We use a pre-built CentOS 5 image with compilers installed as part of the
standard build. To build this yourself, you can do:

```bash
docker login
(cd scripts && docker build -t bioconda/bioconda-builder .)
```

Then test a recipe with:

```bash
docker run -v `pwd`:/bioconda-recipes bioconda/bioconda-builder --packages your_package
```

If you wish the open a bash shell in the Docker container for manual debugging:

```bash
docker run -i -t --entrypoint /bin/bash bioconda/bioconda-builder
```

## The bioconda build system
This repository is set up on [Travis CI](https://travis-ci.org) such that on
every pull request, the following steps are performed once within the Docker
CentOS 5 container and once within the OSX build environment:

- find all recipes in the `recipes` dir
- filter out recipes that have already been uploaded to the bioconda channel
- parse the remaining recipes to recursively find dependencies
- topologically sort the recipes such that when they are built in order,
  dependency packages are built first
- build and test each recipe
- add the recipe to the "local" channel so that subsequent recipes in this
  build can use it as a dependency if needed

If all recipes build and test without error, the pull request can be merged
with the master branch. Upon merging, Travis-CI will detect the merge and the
same steps will be performed again. In addition, at the end of the build, all
built packages will be uploaded to the bioconda channel. This means that as
soon as the Travis-CI tests pass on the master branch, the packages are now
publicly available to all users.

### Dependencies

There is currently no mechanism to define, in the `meta.yaml` file, that
a particular dependency should come from a particular channel. This means that
a recipe must have its dependencies in one of the following:

- as-yet-unbuilt recipes in the repo included in the PR
- `bioconda` channel
- `r` channel
- default Anaconda channel

Otherwise, you will have to write the recipes for those dependencies and
include them in the PR. `conda skeleton` is very useful for Python (PyPI), Perl
(CPAN), and R (CRAN) packages.  Another option is to use `anaconda search -t
conda <dependency name>` to look for other packages built by others. Inspecting
those recipes can give some clues into building a version of the dependency for
bioconda.

### Python versions
By default, Python recipes (those that have `python` listed as a dependency)
must be successfully built and tested on Python 2.7, 3.4, and 3.5 in order to
pass. However, many Python packages are not fully compatible across all Python
versions. Use the [preprocessing
selectors](http://conda.pydata.org/docs/building/meta-yaml.html#preprocessing-selectors)
in the meta.yaml file along with the `build/skip` entry to indicate that
a recipe should be skipped.

For example, a recipe that only runs on Python 2.7 should include the
following:

```yaml
build:
  skip: True  # [not py27]
```

Or a package that only runs on Python 3.4 and 3.5:

```yaml
build:
  skip: True # [py27]
```

Alternatively, for straightforward compatibility fixes you can apply a [patch
in the
meta.yaml](http://conda.pydata.org/docs/building/meta-yaml.html#patches).

### Creating Bioconductor recipes

See [`scripts/bioconductor/README.md`](scripts/bioconductor/README.md) for
details on creating and updating Bioconductor recipes.

### Creating and updating UCSC tools

See [`scripts/ucsc/README.md`](scripts/ucsc/README.md) for details on creating
and updating recipes for UCSC programs.
