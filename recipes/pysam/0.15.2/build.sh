#!/bin/bash

# linking htslib, see:
# http://pysam.readthedocs.org/en/latest/installation.html#external
# https://github.com/pysam-developers/pysam/blob/v0.9.0/setup.py#L79
export CFLAGS="-I$PREFIX/include -DHAVE_LIBDEFLATE"
export CPPFLAGS="-I$PREFIX/include -DHAVE_LIBDEFLATE"
export LDFLAGS="-L$PREFIX/lib"

export HTSLIB_LIBRARY_DIR=$PREFIX/lib
export HTSLIB_INCLUDE_DIR=$PREFIX/include
$PYTHON -m pip install . --ignore-installed --no-deps -vv
