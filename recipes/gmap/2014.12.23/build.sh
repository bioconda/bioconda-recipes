#!/bin/sh
export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
env MAX_READLENGTH=500 ./configure --prefix=$PREFIX --enable-zlib --disable-simd
make
make install prefix=$PREFIX
