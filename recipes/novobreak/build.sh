#!/bin/bash

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

cd samtools
make clean
make

cd ..
make
mkdir -p $PREFIX/bin
cp novoBreak $PREFIX/bin
