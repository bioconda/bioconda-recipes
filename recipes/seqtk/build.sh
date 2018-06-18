#!/bin/bash

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include


make all
mkdir -p $PREFIX/bin
cp -f seqtk $PREFIX/bin/
