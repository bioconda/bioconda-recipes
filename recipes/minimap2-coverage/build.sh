#!/bin/bash

mkdir -p $PREFIX/bin

export CPATH=${PREFIX}/include
cd minimap2-coverage

make INCLUDES="-I$PREFIX/include" CFLAGS="-g -Wall -O2 -Wc++-compat -L$PREFIX/lib" minimap2-coverage
cp minimap2-coverage $PREFIX/bin
