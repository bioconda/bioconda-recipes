#!/bin/bash
set -euo pipefail

export PATH=/anaconda/bin:$PATH

if [[ $TRAVIS_OS_NAME = "linux" ]]
then
    USE_DOCKER="--docker"
else
    USE_DOCKER=""
fi

set -x; bioconda-utils build recipes config.yml $USE_DOCKER $BIOCONDA_UTILS_ARGS; set +x;

# build package documentation
if [[ $TRAVIS_OS_NAME = "linux" && $SUBDAG = 0 ]]
then
  if [[ $TRAVIS_BRANCH = "master" && "$TRAVIS_PULL_REQUEST" = false ]]
  then
    scripts/build-docs.sh
  fi
fi
