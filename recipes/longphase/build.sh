#!/bin/bash

set -xe

# https://bioconda.github.io/troubleshooting.html#zlib-errors
export CFLAGS="${CFLAGS} -I$PREFIX/include"
export LDFLAGS="${LDFLAGS} -L$PREFIX/lib"
export CPATH=${PREFIX}/include

autoreconf -i
./configure --prefix=$PREFIX
make CC=$CC CXX=$CXX -j ${CPU_COUNT}
mkdir -p $PREFIX/bin
cp longphase $PREFIX/bin
