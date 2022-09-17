#!/bin/bash

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

make
#CFLAGS="${CFLAGS} -g -w -O3 -Wsign-compare "
mkdir -p $PREFIX/bin
cp bmtools $PREFIX/bin
cp bmDMR $PREFIX/bin
