# The bioconda channel

[Conda](http://anaconda.org) is a platform and language independent package manager, that sports easy distribution, installation and version management of software.
The [bioconda channel](https://anaconda.org/bioconda) is a Conda channel providing bioinformatics related packages.
This repository hosts the corresponding recipes.

Please visit https://bioconda.github.io for details.

# Building packages

Building and uploading packages requires user permissions to the bioconda
organization on http://anaconda.org. Please post in the
[team thread on GitHub](https://github.com/bioconda/recipes/issues/1) to ask for
permission.

## Linux

We build Linux packages inside a CentOS 5 docker container to maintain
compatibility across multiple systems. To build for a specific package run:

    docker run --net=host --rm=true -i -t -v `pwd`:/tmp/conda-recipes bioconda/bioconda-builder /bin/bash /tmp/conda-recipes/update_packages_docker.sh your_package

Leave off `your_package` to check all of the packages and do builds only if the
latest is not present in the `bioconda` channel. You can also specify multiple
packages and force package building or build for multiple platforms. Run
`update_packages.py --help` for command line options.

To run the Docker script you need to have two files in your `recipes` directory:
`anaconda-user.txt` and `anaconda-pass.txt` that contain your anaconda.org user
and password. The build scripts will authenticate with these, but will require a
manual okay. This is the only non-automated step in the build and upload process.

We use a pre-built CentOS 5 package with compilers installed as part of the
standard build. To build this yourself and push a new container to
[Docker Hub](https://hub.docker.com/r/bioconda), you can do:

    cd docker && docker build -t bicoonda/bioconda-builder .
    docker push bioconda/bioconda-builder

If you'd like to bootstrap from a bare CentOS and install all
the packages yourself for testing or development, use the fullbuild script:

    docker run --net=host --rm=true -i -t -v `pwd`:/tmp/conda-recipes centos:centos5 /bin/bash /tmp/conda-recipes/update_packages_docker_fullbuild.sh your_package

## OSX

For packages that build on OSX, run:

    python update_packages.py your_package

or leave off `your_package` to try and build all out of date packages. Packages
that fail to build on OSX should get added to `CUSTOM_TARGETS` in
`update_binstar_packages.py` to define the platforms they build on.
