#!/bin/bash

if [ -d /tmp/workspace/miniconda ]; then
    # skip the following if cache was restored
    exit 0
fi
mkdir -p /tmp/workspace
pip install pyyaml
./simulate-travis.py --bootstrap /tmp/workspace/miniconda --overwrite
conda clean -y --all
