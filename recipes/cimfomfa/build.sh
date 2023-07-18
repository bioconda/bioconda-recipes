#!/bin/bash
mkdir -p $PREFIX/include
mkdir -p $PREFIX/lib
export CFLAGS="${CFLAGS} -fcommon"
export CXXFLAGS="${CXXFLAGS} -fcommon"
./configure --prefix=$PREFIX --disable-shared
make
make install 
