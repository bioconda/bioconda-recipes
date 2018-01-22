#!/bin/bash
set -eu

# Set path
echo 'export PATH="/tmp/workspace/miniconda/bin:$PATH"' >> $BASH_ENV

if [[ ! -d /tmp/workspace/miniconda ]]; then
    # setup conda and bioconda-utils if not loaded from cache
    mkdir -p /tmp/workspace

    # step 1: download and install miniconda
    if [[ $OSTYPE == darwin* ]]; then
        tag="MacOS"
    elif [[ $OSTYPE == linux* ]]; then
	tag="Linux"
    else
	echo "Unsupported OS: $OSTYPE"
	exit 1
    fi
    bash <(curl -s https://repo.continuum.io/miniconda/Miniconda3-$MINICONDA_VER-$tag-x86_64.sh) -b -p /tmp/workspace/miniconda
    source $BASH_ENV

    # step 2: setup channels
    conda config --add channels defaults
    conda config --add channels conda-forge
    conda config --add channels bioconda

    # step 3: install bioconda-utils
    conda install -y --file https://raw.githubusercontent.com/bioconda/bioconda-utils/$BIOCONDA_UTILS_TAG/bioconda_utils/bioconda_utils-requirements.txt
    # add github to known hosts such that pip does not ask
    mkdir -p ~/.ssh
    ssh-keyscan -H github.com >> ~/.ssh/known_hosts
    pip install git+https://github.com/bioconda/bioconda-utils.git@$BIOCONDA_UTILS_TAG

    # step 4: cleanup
    conda clean -y --all
fi

# Fetch the master branch for comparison (this can fail locally, if git remote 
# is configured via ssh and this is executed in a container).
git fetch origin +master:master || true
