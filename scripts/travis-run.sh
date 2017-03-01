#!/bin/bash
set -euo pipefail

if [[ $TRAVIS_BRANCH != "master" && $TRAVIS_PULL_REQUEST == "false" && $TRAVIS_REPO_SLUG == "bioconda/bioconda-recipes" ]]
then
    echo ""
    echo "Tests are skipped for pushes to the main bioconda-recipes repo."
    echo "If you have opened a pull request, please see the full tests for that PR."
    echo "See https://bioconda.github.io/build-system.html for details"
    echo ""
    exit 0
fi

# determine recipes to build
if [[ $TRAVIS == "false" ]]
then
    RANGE_ARG="--git-range master HEAD"
else
    RANGE="$TRAVIS_BRANCH HEAD"
    if [ $TRAVIS_PULL_REQUEST == "false" ]
    then
        RANGE="${TRAVIS_COMMIT_RANGE/.../ }"
    fi

    RANGE_ARG=""
    set +e
    git diff --exit-code --name-only $RANGE scripts/env_matrix.yml
    ENV_CHANGE=$?
    set -e
    if [ $ENV_CHANGE -eq 1 ] || [ $TRAVIS_EVENT_TYPE == "cron" ]
    then
        # case 1: env matrix changed or this is a cron job. In this case
        # consider all recipes.
        echo "considering all recipes because either env matrix was changed or build is triggered via cron"
    else
        # case 2: consider only recipes that (a) changed since the last build
        # on master, or (b) changed in this pull request compared to the target
        # branch.
        RANGE_ARG="--git-range $RANGE"
    fi
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

PUSH_STATUS=""
COMMIT_ARG=""
if [[ $TRAVIS = "true" ]]
then
    PUSH_STATUS='--push-status'
    COMMIT_ARG="--commit $TRAVIS_COMMIT"
fi
set -x
bioconda-utils lint recipes config.yml \
    $RANGE_ARG \
    --cache .cache
set +x

set -x; bioconda-utils build recipes config.yml $USE_DOCKER $BIOCONDA_UTILS_ARGS $RANGE_ARG; set +x;


if [[ $TRAVIS_OS_NAME = "linux" ]]
then
    if [[ $TRAVIS_BRANCH = "master" && "$TRAVIS_PULL_REQUEST" = "false" ]]
    then
        echo "Push containers to quay.io"
        cat $CONTAINER_PUSH_COMMANDS_PATH
        bash $CONTAINER_PUSH_COMMANDS_PATH
    fi
fi
