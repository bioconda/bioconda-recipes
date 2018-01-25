#!/bin/bash
set -eu

WORKSPACE=/tmp/workspace

# Set path
echo "export PATH=$WORKSPACE/miniconda/bin:$PATH" >> $BASH_ENV

if [[ ! -d $WORKSPACE/miniconda ]]; then
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
    source $BASH_ENV

    # step 2: setup channels
    conda config --add channels defaults
    conda config --add channels conda-forge
    conda config --add channels bioconda

    # step 3: install bioconda-utils
    conda install -y --file bioconda_utils/bioconda_utils-requirements.txt

    # step 4: cleanup
    conda clean -y --all

    # Add local channel as highest priority
    conda index $WORKSPACE/miniconda/conda-bld/linux-64 $WORKSPACE/miniconda/conda-bld/osx-64 $WORKSPACE/miniconda/conda-bld/noarch
    conda config --add channels file://anaconda/conda-bld

    pip install -r pip-test-requirements.txt
    pip install -r pip-requirements.txt
fi

source $BASH_ENV
conda config --get

ls $WORKSPACE/miniconda/conda-bld
ls $WORKSPACE/miniconda/conda-bld/noarch
