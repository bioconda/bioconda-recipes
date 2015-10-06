#!/bin/bash

if [[ $TRAVIS_OS_NAME = "linux" ]]
then
    # run CentOS5 based docker container
    docker run -e TRAVIS_BRANCH -e TRAVIS_PULL_REQUEST -e ANACONDA_TOKEN -e CONDA_PY -e CONDA_NPY -v `pwd`:/tmp/conda-recipes bioconda/bioconda-builder /bin/build-packages.sh /tmp/conda-recipes
else
    # install conda
    wget https://repo.continuum.io/miniconda/Miniconda-latest-MacOSX-x86_64.sh
    bash Miniconda3-latest-Linux-x86_64.sh -b -p /tmp/conda-build/anaconda
    export PATH=/tmp/conda-build/anaconda/bin:$PATH
    mkdir -p /tmp/conda-build/anaconda/conda-bld/linux-64 # workaround for bug in current conda
    conda install -y conda conda-build anaconda-client

    # setup bioconda channel
    conda config --add channels bioconda

    # build packages
    scripts/build-packages.sh .
fi
