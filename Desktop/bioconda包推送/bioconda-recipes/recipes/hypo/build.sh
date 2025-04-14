#!/bin/bash

export CFLAGS=-I$PREFIX/include
export CXXFLAGS=-I$PREFIX/include
export LDFLAGS=-L$PREFIX/lib

mkdir -p $PREFIX/bin
rm -rf build
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Conda ..
make
#make CC=${CC} CFLAGS="${CFLAGS} -L${PREFIX}/lib"  CXX=${CXX} CXXFLAGS="${CXXFLAGS} -L${PREFIX}/lib" LDFLAGS="${LDFLAGS}"
cp ./bin/hypo $PREFIX/bin/hypo
