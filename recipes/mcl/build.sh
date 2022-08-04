#!/bin/bash
mkdir -p $PREFIX/bin
export CFLAGS="${CFLAGS} -fcommon"
export CXXFLAGS="${CXXFLAGS} -fcommon"
./configure --prefix=$PREFIX --enable-blast
make
make install 



