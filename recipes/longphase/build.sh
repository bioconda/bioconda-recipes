#!/bin/bash

set -xe

# https://bioconda.github.io/troubleshooting.html#zlib-errors
export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include

cd $SRC_DIR/longphase*

autoreconf -i
./configure --prefix=$PREFIX
make -j ${CPU_COUNT}
make install
