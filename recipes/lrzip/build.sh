#!/bin/bash

export CFLAGS="-O2 -fomit-frame-pointer -I$PREFIX/include $CFLAGS"
export CXXFLAGS="-O2 -fomit-frame-pointer -I$PREFIX/include $CXXFLAGS"

./configure --prefix=$PREFIX 
make --jobs=${CPU_COUNT}
make install

