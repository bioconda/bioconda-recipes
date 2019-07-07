#!/bin/bash

export CFLAGS="-I$PREFIX/include"
#export LDFLAGS="-L$PREFIX/lib"

export CPATH=${PREFIX}/include


mkdir -p $PREFIX/bin
mkdir -p $PREFIX/lib

mkdir -p build
cd build
cmake ..
make
cp src/minnow $PREFIX/bin/ 
cp src/fixfasta $PREFIX/bin/ 

cp src/libfixfastalib.a $PREFIX/lib/
cp src/libminnowlib.a $PREFIX/lib/
