#!/bin/bash

# For zlib: https://bioconda.github.io/troubleshooting.html#zlib
export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include

nucleoatac run --help
pyatac --help

python -c "import pyatac.fragmentsizes"