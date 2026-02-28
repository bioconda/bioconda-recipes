#!/bin/bash

# linking htslib, see:
# http://pysam.readthedocs.org/en/latest/installation.html#external
# https://github.com/pysam-developers/pysam/blob/v0.9.0/setup.py#L79
export CFLAGS="-I$PREFIX/include -DHAVE_LIBDEFLATE"
export CPPFLAGS="-I$PREFIX/include -DHAVE_LIBDEFLATE"
export LDFLAGS="-L$PREFIX/lib"

# Fix for failing build of 0.20.0 on Linux
# See https://github.com/pysam-developers/pysam/issues/1146
platform=$(uname)
if [[ "$platform" == "Linux" ]]; then
    export CFLAGS="-fPIC $CFLAGS"
fi

$PYTHON setup.py install --single-version-externally-managed --record=record.txt
