#!/bin/bash

mkdir -p $PREFIX/bin
export CFLAGS="-I$PREFIX/include -g -Wall -O2 -Wc++-compat -Wno-unused-function"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include

make 
mv bgt  $PREFIX/bin

