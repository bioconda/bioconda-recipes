#!/bin/bash
set -eu

WORKSPACE=$(pwd)

# Common definitions from latest bioconda-common master have to be downloaded before setup.sh is executed.
# This file can be used to set MINICONDA_VER.
source .circleci/common.sh

# Set path
echo "export PATH=$WORKSPACE/miniconda/bin:$PATH" >> $BASH_ENV
source $BASH_ENV

if [[ ! -d $WORKSPACE/miniconda ]]; then
    # setup conda and dependencies if not loaded from cache
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

    conda config --system --add channels defaults
    conda config --system --add channels bioconda
    conda config --system --add channels conda-forge

    conda config --system --remove repodata_fns current_repodata.json || true
    conda config --system --prepend repodata_fns repodata.json

    # step 3: install bioconda-utils and test requirements
    conda install -y --file bioconda_utils/bioconda_utils-requirements.txt --file test-requirements.txt

    # step 4: cleanup
    conda clean -y --all

    # Add local channel as highest priority
    mkdir -p $WORKSPACE/miniconda/conda-bld/{noarch,linux-64,osx-64}
    conda index $WORKSPACE/miniconda/conda-bld
    conda config --system --add channels file://$WORKSPACE/miniconda/conda-bld
fi

conda config --get

ls $WORKSPACE/miniconda/conda-bld
ls $WORKSPACE/miniconda/conda-bld/noarch
