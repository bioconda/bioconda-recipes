#!/bin/bash

export C_INCLUDE_PATH="$PREFIX/include"
export CPATH="$PREFIX/include"
export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

mkdir -p $PREFIX/bin

make
cp minimap2 $PREFIX/bin
