#!/bin/bash

set -e

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH="${PREFIX}/include"

# Override Makefile -mtune=native
export CXXFLAGS="-mtune=generic"

# TODO: remove when seqan is updated upstream
#rm -rf unicycler/include/seqan
#mv seqan/include/seqan unicycler/include/seqan

python -m pip install --no-deps --ignore-installed .
