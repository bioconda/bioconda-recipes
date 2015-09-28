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

    docker run --net=host --rm=true -i -t -v `pwd`:/tmp/conda-recipes centos:centos5 /bin/bash /tmp/conda-recipes/update_binstar_packages_docker.sh your_package

Leave off `your_package` to check all of the packages and do builds only if the
latest is not present in the `bioconda` channel.

To run the Docker script you need to have two files in your `recipes` directory:
`anaconda-user.txt` and `anaconda-pass.txt` that contain your anaconda.org user
and password. The build scripts will authenticate with these, but will require a
manual okay. This is the only non-automated step in the build and upload process.

In some cases, building the docker container can take more time than building
the conda package. If so, you can build a container locally and use that for
building instead of the centos:centos5 container. Use the
`update_binstar_packages_docker_prebuilt.sh` script when using this strategy:

    (cd docker && docker build -t bioconda-builder .)
    docker run --net=host --rm=true -i -t -v `pwd`:/tmp/conda-recipes bioconda-builder /bin/bash /tmp/conda-recipes/update_binstar_packages_docker.sh your_package


## OSX

For packages that build on OSX, run:

    python update_binstar_packages.py your_package

or leave off `your_package` to try and build all out of date packages. Packages
that fail to build on OSX should get added to `CUSTOM_TARGETS` in
`update_binstar_packages.py` to define the platforms they build on.
