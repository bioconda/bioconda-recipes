#!/bin/bash
set -euo pipefail

export PATH=/anaconda/bin:$PATH

if [[ $TRAVIS_BRANCH = "master" && "$TRAVIS_PULL_REQUEST" = false ]]
then
   export CONTAINER_PUSH_COMMANDS_PATH=${TRAVIS_BUILD_DIR}/container_push_commands.sh
   touch $CONTAINER_PUSH_COMMANDS_PATH
fi

if [[ $TRAVIS_OS_NAME = "linux" ]]
then
    USE_DOCKER="--docker"
else
    USE_DOCKER=""
fi

set -x; bioconda-utils build recipes config.yml $USE_DOCKER $BIOCONDA_UTILS_ARGS; set +x;


# Documentation is now built on bioconda-utils
#
# build package documentation
# if [[ $TRAVIS_OS_NAME = "linux" ]]
# then
#     if [[ $TRAVIS_BRANCH = "master" && "$TRAVIS_PULL_REQUEST" = false ]]
#     then
#         echo "Push containers to quay.io"
#         cat $CONTAINER_PUSH_COMMANDS_PATH
#         bash $CONTAINER_PUSH_COMMANDS_PATH
#         if [[ $SUBDAG = 0 ]]
#         then
#             scripts/build-docs.sh
#         fi
#     fi
# fi
