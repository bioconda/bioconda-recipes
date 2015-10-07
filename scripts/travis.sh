#!/bin/bash

if [[ $TRAVIS_OS_NAME = "linux" ]]
then
    # run CentOS5 based docker container
    docker run -e TRAVIS_BRANCH -e TRAVIS_PULL_REQUEST -e ANACONDA_TOKEN -e CONDA_PY -e CONDA_NPY -v `pwd`:/bioconda-recipes bioconda/bioconda-builder
    exit $?
else
    # install conda
    wget https://repo.continuum.io/miniconda/Miniconda3-latest-MacOSX-x86_64.sh
    bash Miniconda3-latest-MacOSX-x86_64.sh -b -p /anaconda
    export PATH=/anaconda/bin:$PATH
    mkdir -p /anaconda/conda-bld/osx-64 # workaround for bug in current conda
    conda install -y conda conda-build anaconda-client pyyaml toolz jinja2 nose

    # setup bioconda channel
    conda config --add channels bioconda

    # build packages
    scripts/build-packages.py --repository .
    exit $?
fi
