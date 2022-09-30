#!/bin/bash

#export C_INCLUDE_PATH=${PREFIX}/include
#export LIBRARY_PATH=${PREFIX}/lib
export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

make
mkdir -p $PREFIX/bin
cp Genrich $PREFIX/bin

