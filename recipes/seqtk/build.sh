#!/bin/bash

#export C_INCLUDE_PATH=${PREFIX}/include
#export LIBRARY_PATH=${PREFIX}/lib

export CFLAGS="-I$PREFIX/include -g -Wall -O2 -Wno-unused-function"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include

make all
mkdir -p $PREFIX/bin
cp -f seqtk $PREFIX/bin/
