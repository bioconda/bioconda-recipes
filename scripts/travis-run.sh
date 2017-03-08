#!/bin/bash
set -euo pipefail
# Set some defaults
set +u
[[ -z $DOCKER_ARG ]] && DOCKER_ARG=""
[[ -z $TRAVIS ]] && TRAVIS="false"
[[ -z $BIOCONDA_UTILS_LINT_ARGS ]] && BIOCONDA_UTILS_LINT_ARGS=""
[[ -z $RANGE_ARG ]] && RANGE_ARG="--git-range HEAD"
[[ -z $DISABLE_BIOCONDA_UTILS_BUILD_GIT_RANGE_CHECK  ]] && DISABLE_BIOCONDA_UTILS_BUILD_GIT_RANGE_CHECK="false"
set -u

if [[ $TRAVIS_BRANCH != "master" && $TRAVIS_PULL_REQUEST == "false" && $TRAVIS_REPO_SLUG == "bioconda/bioconda-recipes" ]]
then
    echo ""
    echo "Tests are skipped for pushes to the main bioconda-recipes repo."
    echo "If you have opened a pull request, please see the full tests for that PR."
    echo "See https://bioconda.github.io/build-system.html for details"
    echo ""
    exit 0
fi

# determine recipes to build. If building locally, build anything that changed
# since master. If on travis, only build the commit range included in the push
# or the pull request.
if [[ $TRAVIS = "true" ]]
then
    RANGE="$TRAVIS_BRANCH HEAD"
    if [ $TRAVIS_PULL_REQUEST == "false" ]
    then
        RANGE="${TRAVIS_COMMIT_RANGE/.../ }"
    fi

    # If the environment vars changed (e.g., boost, R, perl) then there's no
    # good way of knowing which recipes need rebuilding so we check them all.
    #
    # For cron jobs we always want to check everything.
    set +e
    git diff --exit-code --name-only $RANGE scripts/env_matrix.yml
    ENV_CHANGE=$?
    set -e
    if [ $ENV_CHANGE -eq 1 ] || [ $TRAVIS_EVENT_TYPE = "cron" ]
    then
        # case 1: env matrix changed or this is a cron job. In this case
        # consider all recipes.
        RANGE_ARG=""
        echo "considering all recipes because either env matrix was changed or build is triggered via cron"
    else
        # case 2: consider only recipes that (a) changed since the last build
        # on master, or (b) changed in this pull request compared to the target
        # branch.
        RANGE_ARG="--git-range $RANGE"
    fi
fi

export PATH=/anaconda/bin:$PATH

# On travis we always run on docker for linux. This may not always be the case
# for local testing.
if [[ $TRAVIS_OS_NAME = "linux" && $TRAVIS = "true" ]]
then
    DOCKER_ARG="--docker"
fi

# If this build corresponds to the merge into master, we will be detecting this
# in bioconda-utils and will be pushing containers to quay.io.
if [[ $TRAVIS_BRANCH = "master" && "$TRAVIS_PULL_REQUEST" = "false" ]]
then
    echo "Create Container push commands file: ${TRAVIS_BUILD_DIR}/container_push_commands.sh"
    export CONTAINER_PUSH_COMMANDS_PATH=${TRAVIS_BUILD_DIR}/container_push_commands.sh
    touch $CONTAINER_PUSH_COMMANDS_PATH
else
    # if building master branch, do not lint
    set -x; bioconda-utils lint recipes config.yml $RANGE_ARG $BIOCONDA_UTILS_LINT_ARGS; set +x
fi


if [[ $DISABLE_BIOCONDA_UTILS_BUILD_GIT_RANGE_CHECK = "true" ]]
then
    echo
    echo "DISABLE_BIOCONDA_UTILS_BUILD_GIT_RANGE_CHECK is true."
    echo "A comprehensive check will be performed to see what needs to be built."
    RANGE_ARG=""
fi
set -x; bioconda-utils build recipes config.yml $DOCKER_ARG $BIOCONDA_UTILS_BUILD_ARGS $RANGE_ARG; set +x;

if [[ $TRAVIS_OS_NAME = "linux" ]]
then
    if [[ $TRAVIS_BRANCH = "master" && "$TRAVIS_PULL_REQUEST" = "false" ]]
    then
        echo "Push containers to quay.io"
        cat $CONTAINER_PUSH_COMMANDS_PATH
        bash $CONTAINER_PUSH_COMMANDS_PATH
    fi
fi
