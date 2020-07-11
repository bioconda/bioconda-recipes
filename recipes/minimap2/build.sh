#!/bin/bash

mkdir -p $PREFIX/bin

make INCLUDES="-I$PREFIX/include" CFLAGS="-g -Wall -O2 -Wc++-compat -L$PREFIX/lib"
cp minimap2 misc/paftools.js $PREFIX/bin
