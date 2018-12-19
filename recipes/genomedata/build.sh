#!/bin/bash

export HDF5_DIR=$PREFIX
# Remove -DNDEBUG from CPPFLAGS to keep assertions
# See https://bitbucket.org/hoffmanlab/genomedata/issues/47/assert-statements-from
export CPPFLAGS='-D_FORTIFY_SOURCE=2 -O2'

$PYTHON -m pip install -vv --no-deps --no-cache-dir --ignore-installed . 
