#!/bin/bash

mkdir -p $PREFIX/bin
mkdir build
cd build
export CFLAGS="$CFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
cmake ..
make
cp spring $PREFIX/bin
