#!/bin/bash

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

mkdir -p $PREFIX/bin

make
cp minimap2 $PREFIX/bin
