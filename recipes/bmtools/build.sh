#!/bin/bash

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

cd htslib*
make CC=$CC CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}"
cd ..

make pycd CC=$CC CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}"
#CFLAGS="${CFLAGS} -g -w -O3 -Wsign-compare "
mkdir -p $PREFIX/bin
cp bmtools $PREFIX/bin
cp bmDMR $PREFIX/bin
