# The bioconda channel

[![Build Status](https://travis-ci.org/bioconda/bioconda-recipes.svg?branch=master)](https://travis-ci.org/bioconda/bioconda-recipes)

[Conda](http://anaconda.org) is a platform and language independent package manager, that sports easy distribution, installation and version management of software.
The [bioconda channel](https://anaconda.org/bioconda) is a Conda channel providing bioinformatics related packages.
This repository hosts the corresponding recipes.

## User guide

Please visit https://bioconda.github.io for details.

## Developer guide

If you want to contribute new packages to Bioconda, you are invited to join the Bioconda team.
Please post in the
[team thread on GitHub](https://github.com/bioconda/recipes/issues/1) to ask for
permission.

We build Linux packages inside a CentOS 5 docker container to maintain
compatibility across multiple systems. The steps below describe how to
contribute a new package. It is assumed you have
[docker](https://www.docker.com/) and [git](https://git-scm.com/) installed.

### Step 1: Create a new recipe

Fork this repository or create a new branch to work in. Within the new branch,
[create a recipe](http://conda.pydata.org/docs/building/build.html)
(`your_package` in this example) in the `recipes` directory.

### Step 2: Test the recipe

When the recipe
is ready first test it with your local conda installation via

    conda build recipes/your_package

Then, you can test it in the docker container with:

    docker run -v `pwd`:/bioconda-recipes bioconda/bioconda-builder --packages your_package

To optionally build for a specific Python version, provide the `CONDA_PY`
environmental variable. For example, to build specifically for Python 3.4:

    docker run -e CONDA_PY=34 -v `pwd`:/bioconda-recipes bioconda/bioconda-builder --packages your_package

To optionally build and test all packages (if they don't already exist), leave off the
package name:

    docker run -v `pwd`:/tmp/conda-recipes bioconda/bioconda-builder

If rebuilding a previously-built package and the version number hasn't changed, be sure to increment the build number in `meta.yaml` (the default build number is 0):

    build:
      number: 1

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

If you want to promote the Bioconda installation of your package, we recommend to add the following badge to your homepage:

    [![bioconda-badge](https://img.shields.io/badge/install%20with-bioconda-brightgreen.svg?style=flat-square)](http://bioconda.github.io)

This will display as [![bioconda-badge](https://img.shields.io/badge/install%20with-bioconda-brightgreen.svg?style=flat-square)](https://bioconda.github.io). For other styles, replace ``?style=flat-square`` with ``?style=flat`` or ``?style=plastic``.

### Building packages for Mac OSX

If you want your package to be built for Mac OSX as well, you have to add it to
the ``osx-whitelist.txt`` file in the root of this repository.

### Managing multiple versions of a package

If there is interest to keep multiple versions of a package or to explicitly build an older version of a package,
you can store those versions in subdirectories of the corresponding recipe, e.g.:

```
java-jdk/
├── 7.0.91
│   ├── build.sh
│   └── meta.yaml
├── build.sh
└── meta.yaml
```

There should always be a primary in the root directory of a package that is updated when new releases are made.

### Other notes

We use a pre-built CentOS 5 image with compilers installed as part of the
standard build. To build this yourself, you can do:

    docker login
    cd scripts && docker build -t bicoonda/bioconda-builder .

### Creating Bioconductor recipes

See [`scripts/bioconductor/README.md`](scripts/bioconductor/README.md) for
details on creating and updating Bioconductor recipes.
