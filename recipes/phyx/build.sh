#!/bin/bash
export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib -Wl,-rpath ${PREFIX}/lib"
export CPATH=${PREFIX}/include


mkdir -p $PREFIX/bin
cd src
./configure  --prefix=$PREFIX
make
make install
