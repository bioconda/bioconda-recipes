#!/bin/bash

export CFLAGS="-O2 -march=native -fomit-frame-pointer -I$PREFIX/include $CFLAGS"
export CXXFLAGS="-O2 -march=native -fomit-frame-pointer -I$PREFIX/include $CXXFLAGS"

./configure --prefix=$PREFIX 
make
make install

