#!/bin/bash
set -euo pipefail

export PATH=/tmp/anaconda/bin:$PATH

if [[ $TRAVIS_OS_NAME = "linux" ]]
then

    sudo bioconda-utils build recipes config.yml --docker --loglevel=info

    if [[ $SUBDAG = 0 ]]
    then
      if [[ $TRAVIS_BRANCH = "master" && "$TRAVIS_PULL_REQUEST" = false ]]
      then
        # build package documentation
        scripts/build-docs.sh
      fi
    fi
else

    sudo bioconda-utils build recipes config.yml --loglevel=info

fi
