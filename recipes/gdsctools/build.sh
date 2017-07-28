#!/bin/bash

# https://github.com/bioconda/bioconda-recipes/pull/5140
# https://github.com/bioconda/bioconda-recipes/pull/5124

$PYTHON setup.py install --single-version-externally-managed --record=record.txt

# Add more build steps here, if they are necessary.

# See
# http://docs.continuum.io/conda/build.html
# for a list of environment variables that are set during the build process.
