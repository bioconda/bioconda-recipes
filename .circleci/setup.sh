#!/bin/bash

if [ ! -d /tmp/workspace/miniconda ]; then
    # setup conda and bioconda-utils if not loaded from cache
    mkdir -p /tmp/workspace
    pip install pyyaml
    ./simulate-travis.py --bootstrap /tmp/workspace/miniconda --overwrite
    conda clean -y --all
fi

# Set path
echo 'export PATH="/tmp/workspace/miniconda/bin:$PATH"' >> $BASH_ENV
# fetch the master branch for comparison
git fetch origin +master:master
