#!/bin/bash

set -e

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include

rm -rf unicycler/include/seqan
mv seqan/include/seqan unicycler/include/seqan

python -m pip install --no-deps --ignore-installed .
