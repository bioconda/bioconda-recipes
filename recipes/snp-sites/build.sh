#!/bin/bash

set -xe

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include

mkdir -p $PREFIX/bin

autoreconf -i -f
./configure --prefix=$PREFIX 
make -j ${CPU_COUNT}
make install
