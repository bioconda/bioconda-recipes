#!/bin/bash
export CPATH=${PREFIX}/include
$PYTHON setup.py install --single-version-externally-managed --record=rec.txt

# Add more build steps here, if they are necessary.

# See
# http://docs.continuum.io/conda/build.html
# for a list of environment variables that are set during the build process.
