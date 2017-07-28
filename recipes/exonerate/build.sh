#!/bin/sh
mkdir -p ${PREFIX}/bin

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib -Wl,-rpath ${PREFIX}/lib"
export CPATH=${PREFIX}/include

./configure --prefix=${PREFIX} --enable-pthreads
make
make install
