#!/bin/bash

mkdir -p $PREFIX/bin
export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include

make 
mv bgt  $PREFIX/bin

