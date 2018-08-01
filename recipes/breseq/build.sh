#!/usr/bin/env bash

set -x -e


export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include

gcc -v

mkdir -p $PREFIX/bin
./configure --prefix=${PREFIX}
make 
make install
