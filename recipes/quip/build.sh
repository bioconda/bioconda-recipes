#!/bin/bash
export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export LIBS="-L$PREFIX/lib"
./configure --prefix=$PREFIX
make install