#!/bin/bash
mkdir -p $PREFIX/bin
export CPATH=${PREFIX}/include
make INCLUDES="-I$PREFIX/include" CFLAGS="-g -Wall -O2 -Wc++-compat -L$PREFIX/lib"
cp minimap2 $PREFIX/bin 