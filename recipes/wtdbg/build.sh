#!/bin/bash

export CFLAGS=-I$PREFIX/include
export CXXFLAGS=-I$PREFIX/include
export LDFLAGS=-L$PREFIX/lib

mkdir -p $PREFIX/bin

make CC=${CC} CFLAGS="${CFLAGS} -L${PREFIX}/lib"  CXX=${CXX} CXXFLAGS="${CXXFLAGS} -L${PREFIX}/lib" LDFLAGS="${LDFLAGS}"

cp wtdbg2 wtdbg-cns wtpoa-cns $PREFIX/bin
