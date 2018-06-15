#!/bin/bash

# For zlib: https://bioconda.github.io/troubleshooting.html#zlib
export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include

$PYTHON setup.py install --recythonize --single-version-externally-managed --record=record.txt
