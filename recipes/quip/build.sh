#!/bin/bash
export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export LIBS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include
./configure --prefix=$PREFIX
make install