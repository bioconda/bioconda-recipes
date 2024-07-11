#!/bin/bash

set -xe

# https://bioconda.github.io/troubleshooting.html#zlib-errors
export CFLAGS="${CFLAGS} -I$PREFIX/include"
export LDFLAGS="${LDFLAGS} -L$PREFIX/lib"
export CPATH=${PREFIX}/include

autoreconf -i
./configure --prefix=$PREFIX
make CC=$CXX -j ${CPU_COUNT}
make install
