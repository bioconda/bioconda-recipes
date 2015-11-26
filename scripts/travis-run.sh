#!/bin/bash
set -e

if [[ $TRAVIS_OS_NAME = "linux" ]]
then
    # run CentOS5 based docker container
    travis_wait docker run -e TRAVIS_BRANCH -e TRAVIS_PULL_REQUEST -e ANACONDA_TOKEN -v `pwd`:/bioconda-recipes bioconda/bioconda-builder
else
    export PATH=/anaconda/bin:$PATH
    # build packages
    travis_wait scripts/build-packages.py --repository . --packages `cat osx-whitelist.txt`
fi
