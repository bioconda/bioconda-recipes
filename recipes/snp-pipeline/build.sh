#!/bin/bash

$PYTHON setup.py install --single-version-externally-managed --record=record.txt

# See
# http://docs.continuum.io/conda/build.html
# for a list of environment variables that are set during the build process.
