#!/bin/bash
set -e

if [[ $TRAVIS_OS_NAME = "linux" ]]
then
    # run CentOS5 based docker container
    docker run -e TRAVIS_BRANCH -e TRAVIS_PULL_REQUEST -e ANACONDA_TOKEN -e CONDA_PY -e CONDA_NPY -v `pwd`:/bioconda-recipes bioconda/bioconda-builder
else
    # build packages
    scripts/build-packages.py --repository .
fi
