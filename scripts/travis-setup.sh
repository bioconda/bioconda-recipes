#!/bin/bash
set -e

if [[ $TRAVIS_OS_NAME = "linux" ]]
then
    docker pull bioconda/bioconda-builder
else
    # install conda
    wget https://repo.continuum.io/miniconda/Miniconda3-latest-MacOSX-x86_64.sh
    bash Miniconda3-latest-MacOSX-x86_64.sh -b -p /tmp/anaconda
    mkdir -p /tmp/anaconda/conda-bld/osx-64 # workaround for bug in current conda
    conda install -y conda conda-build anaconda-client pyyaml toolz jinja2 nose

    # setup bioconda channel
    conda config --add channels bioconda
fi
