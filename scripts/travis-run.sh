#!/bin/bash
set -euo pipefail


# obtain recipes that changed in this commit
RECIPES=""
ENV_MATRIX_CHANGED=$(git diff master HEAD --name-only scripts/env_matrix.yml)
if [ -z "$ENV_MATRIX_CHANGED" ]
then
    echo "env matrix changed, considering all recipes"
else
    RECIPES=$(git diff --relative=recipes --name-only $TRAVIS_COMMIT_RANGE recipes/*/meta.yaml recipes/*/*/meta.yaml | xargs dirname)
    echo "considering changed recipes:"
    echo $RECIPES
fi


export PATH=/anaconda/bin:$PATH

if [[ $TRAVIS_BRANCH = "master" && "$TRAVIS_PULL_REQUEST" = "false" ]]
then
   echo "Create Container push commands file: ${TRAVIS_BUILD_DIR}/container_push_commands.sh"
   export CONTAINER_PUSH_COMMANDS_PATH=${TRAVIS_BUILD_DIR}/container_push_commands.sh
   touch $CONTAINER_PUSH_COMMANDS_PATH
fi

if [[ $TRAVIS_OS_NAME = "linux" ]]
then
    USE_DOCKER="--docker"
else
    USE_DOCKER=""
fi

set -x; bioconda-utils build recipes config.yml $USE_DOCKER $BIOCONDA_UTILS_ARGS --packages $RECIPES; set +x;


if [[ $TRAVIS_OS_NAME = "linux" ]]
then
    if [[ $TRAVIS_BRANCH = "master" && "$TRAVIS_PULL_REQUEST" = "false" ]]
    then
        echo "Push containers to quay.io"
        cat $CONTAINER_PUSH_COMMANDS_PATH
        bash $CONTAINER_PUSH_COMMANDS_PATH
    fi
fi
