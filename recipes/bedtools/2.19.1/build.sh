#!/bin/sh

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include

make
mkdir -p $PREFIX/bin
mv bin/* $PREFIX/bin/
