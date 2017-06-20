#!/bin/bash

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include

cd gzstream && make

make
make test
make install