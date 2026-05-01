#!/bin/bash

# linking htslib, see:
# http://pysam.readthedocs.org/en/latest/installation.html#external
# https://github.com/pysam-developers/pysam/blob/v0.9.0/setup.py#L79
export CFLAGS="-I$PREFIX/include -DHAVE_LIBDEFLATE"
export CPPFLAGS="-I$PREFIX/include -DHAVE_LIBDEFLATE"
export LDFLAGS="-L$PREFIX/lib"

$PYTHON setup.py install --single-version-externally-managed --record=record.txt
