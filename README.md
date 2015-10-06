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
is ready, you can test it in the docker container with:

    docker run -t -v `pwd`:/tmp/conda-recipes bioconda/bioconda-builder /bin/build-packages.sh your_package

To optionally build for a specific Python version, provide the `CONDA_PY`
environmental variable. For example, to build specifically for Python 3.4:

    docker run -e CONDA_PY=34 -t -v `pwd`:/tmp/conda-recipes bioconda/bioconda-builder /bin/build-packages.sh your_package

To optionally build all packages (if they don't already exist), leave off the
package name:

    docker run -t -v `pwd`:/tmp/conda-recipes bioconda/bioconda-builder /bin/build-packages.sh

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

##Other notes

We use a pre-built CentOS 5 package with compilers installed as part of the
standard build. To build this yourself and push a new container to
[Docker Hub](https://hub.docker.com/r/bioconda), you can do:

    docker login
    cd docker && docker build -t bicoonda/bioconda-builder .
    docker push bioconda/bioconda-builder

If you'd like to bootstrap from a bare CentOS and install all
the packages yourself for testing or development, use the fullbuild script:

    docker run --net=host --rm=true -i -t -v `pwd`:/tmp/conda-recipes centos:centos5 /bin/bash /tmp/conda-recipes/update_packages_docker_fullbuild.sh your_package

### OSX

For packages that build on OSX, run:

    python update_packages.py your_package

or leave off `your_package` to try and build all out of date packages. Packages
that fail to build on OSX should get added to `CUSTOM_TARGETS` in
`update_binstar_packages.py` to define the platforms they build on.
