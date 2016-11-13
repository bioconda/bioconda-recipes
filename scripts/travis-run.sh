#!/bin/bash
set -euo pipefail

export PATH=/anaconda/bin:$PATH
export CONTAINER_PUSH_COMMANDS_PATH=${TRAVIS_BUILD_DIR}/container_push_commands.sh

touch $CONTAINER_PUSH_COMMANDS_PATH

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
    echo "Push containers to quay.io"
    cat $CONTAINER_PUSH_COMMANDS_PATH
    bash $CONTAINER_PUSH_COMMANDS_PATH
    scripts/build-docs.sh
  fi
fi
