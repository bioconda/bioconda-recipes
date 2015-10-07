# The bioconda channel

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

### Step 1: create a new recipe

Fork this repository or create a new branch to work in. Within the new branch,
[create a recipe](http://conda.pydata.org/docs/building/build.html)
(`your_package` in this example) in the `recipes` directory.

### Step 2: test the recipe

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

### Step 3: submit a pull request

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

### Building packages for Mac OSX

If you want your package to be built for Mac OSX as well, you have to add it to
the ``osx-whitelist.txt`` file in the root of this repository.

### Handling recipes with new dependencies

If your new recipe has dependencies that shall also be included in the
`bioconda` channel, the the following workflow is recommended. Assume recipe
B depends on recipe A. Then:

- submit a PR for recipe A
- wait for PR tests to pass
- once they pass, merge the PR into master
- wait for master branch tests to pass, which will then upload A to the
  bioconda channel
- submit another PR for recipe B. The built recipe A will be available for
      it to use as a dependency.

###Other notes

We use a pre-built CentOS 5 image with compilers installed as part of the
standard build. To build this yourself, you can do:

    docker login
    cd scripts && docker build -t bicoonda/bioconda-builder .
