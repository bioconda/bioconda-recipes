#!/bin/bash

echo 'export PATH="/tmp/workspace/miniconda/bin:$PATH"' >> $BASH_ENV
# fetch the master branch for comparison
git fetch origin +master:master
