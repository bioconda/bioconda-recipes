#!/bin/bash

#export CFLAGS="$CFLAGS -I$PREFIX/include"
#export LDFLAGS="$LDFLAGS -L$PREFIX/lib"

./configure --prefix=$PREFIX --with-htslib="$PREFIX" --with-zlib="$PREFIX"
make
make install
