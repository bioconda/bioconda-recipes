#!/bin/bash

export CFLAGS="-I$PREFIX/include -I$PREFIX/include/ncurses"
export LDFLAGS="-L$PREFIX/lib"
export CC=gcc

./configure --prefix=$PREFIX
make 
make install
