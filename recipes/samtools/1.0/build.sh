#!/bin/sh
export CPPFLAGS="-I$PREFIX/include"
export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
make install prefix=$PREFIX
