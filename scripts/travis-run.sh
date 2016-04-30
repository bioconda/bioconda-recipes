#!/bin/bash
set -euo pipefail

if [[ $TRAVIS_OS_NAME = "linux" ]]
then
    # run CentOS5 based docker container
    docker run -e SUBDAG -e SUBDAGS -e TRAVIS_BRANCH -e TRAVIS_PULL_REQUEST -e ANACONDA_TOKEN -v `pwd`:/bioconda-recipes bioconda/bioconda-builder --env-matrix /bioconda-recipes/scripts/env_matrix.yml

    if [[ $SUBDAG = 0 ]]
    then
      if [[ $TRAVIS_BRANCH = "master" && "$TRAVIS_PULL_REQUEST" = false ]]
      then
        # build package documentation
        scripts/build-docs.sh
      fi
    fi
else
    export PATH=/anaconda/bin:$PATH
    # build packages
    scripts/build-packages.py --repository . --env-matrix scripts/env_matrix.yml
fi
