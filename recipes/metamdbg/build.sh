#!/bin/bash


mkdir -p $PREFIX/bin

export CFLAGS="$CFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"

mkdir build
cd build
cmake ..

make

cp ./bin/metaMDBG $PREFIX/bin
