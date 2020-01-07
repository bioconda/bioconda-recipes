#!/bin/bash
set -e
[[ -z $WORKSPACE ]] && WORKSPACE=`pwd`
[[ -z $BOOTSTRAP ]] && BOOTSTRAP=false
[[ -z $BASH_ENV ]] && BASH_ENV=`mktemp`
[[ -z $USE_DOCKER ]] && USE_DOCKER=true

set -u

# Common definitions from latest bioconda-utils master have to be downloaded before setup.sh is executed.
# This file can be used to set BIOCONDA_UTILS_TAG and MINICONDA_VER.
source .circleci/common.sh

# Set path
echo "export PATH=\"$WORKSPACE/miniconda/bin:$PATH\"" >> $BASH_ENV
source $BASH_ENV

# Make sure the CircleCI config is up to date.
# add upstream as some semi-randomly named temporary remote to diff against
UPSTREAM_REMOTE=__upstream__$(mktemp -u XXXXXXXXXX)
git remote add -t master $UPSTREAM_REMOTE https://github.com/bioconda/bioconda-recipes.git
git fetch $UPSTREAM_REMOTE
if ! git diff --quiet HEAD...$UPSTREAM_REMOTE/master -- .circleci/; then
    echo 'Your bioconda-recipes CI configuration is out of date.'
    echo 'Please update it to the latest version of the upstream master branch.'
    echo ''
    echo 'Have @BiocondaBot attempt to fix this by creating a comment on your PR:'
    echo ''
    echo '   @BiocondaBot update'
    echo ''
    echo 'Once the update commit has been created, update your local copy of'
    echo 'your branch:'
    echo ''
    echo '  git pull'
    echo ''
    echo ''
    echo 'You can also fix this manually, e.g., by running:'
    echo '  git fetch https://github.com/bioconda/bioconda-recipes.git master'
    echo '  git merge FETCH_HEAD'
    echo ''
    exit 1
fi
git remote remove $UPSTREAM_REMOTE


if ! type bioconda-utils 2> /dev/null || [[ $BOOTSTRAP == "true" ]]; then
    echo "Setting up bioconda-utils..."

    # setup conda and bioconda-utils if not loaded from cache
    mkdir -p $WORKSPACE

    # step 1: download and install miniconda
    if [[ $OSTYPE == darwin* ]]; then
        tag="MacOSX"
    elif [[ $OSTYPE == linux* ]]; then
        tag="Linux"
    else
        echo "Unsupported OS: $OSTYPE"
        exit 1
    fi
    curl -L -o miniconda.sh https://repo.continuum.io/miniconda/Miniconda3-$MINICONDA_VER-$tag-x86_64.sh
    bash miniconda.sh -b -p $WORKSPACE/miniconda

    # step 2: setup channels
    $WORKSPACE/miniconda/bin/conda config --system --add channels defaults
    $WORKSPACE/miniconda/bin/conda config --system --add channels bioconda
    $WORKSPACE/miniconda/bin/conda config --system --add channels conda-forge

    # step 3: install bioconda-utils
    $WORKSPACE/miniconda/bin/conda install -y git pip --file https://raw.githubusercontent.com/bioconda/bioconda-utils/$BIOCONDA_UTILS_TAG/bioconda_utils/bioconda_utils-requirements.txt
    $WORKSPACE/miniconda/bin/pip install git+https://github.com/bioconda/bioconda-utils.git@$BIOCONDA_UTILS_TAG

    # step 4: configure local channel
    mkdir -p $WORKSPACE/miniconda/conda-bld/{noarch,linux-64,osx-64}
    $WORKSPACE/miniconda/bin/conda index $WORKSPACE/miniconda/conda-bld
    $WORKSPACE/miniconda/bin/conda config --system --add channels file://$WORKSPACE/miniconda/conda-bld

    # step 5: cleanup
    $WORKSPACE/miniconda/bin/conda clean -y --all
    rm miniconda.sh
fi

# Fetch the master branch for comparison (this can fail locally, if git remote 
# is configured via ssh and this is executed in a container).
if [[ $BOOTSTRAP != "true" ]]; then
    git fetch origin +master:master || true
fi
