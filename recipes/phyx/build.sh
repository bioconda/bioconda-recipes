#!/bin/bash

#export CFLAGS="-I$PREFIX/include"
#export LDFLAGS="-Wl,-rpath -Wl,$PREFIX/lib"
#export CPATH=${PREFIX}/include


mkdir -p $PREFIX/bin
cd src
autoreconf -fi
./configure   --prefix=$PREFIX
make
make install

