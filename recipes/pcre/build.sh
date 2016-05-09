#!/bin/bash

export CFLAGS="-I$PREFIX/include"
export CPPFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

./configure --enable-utf --enable-unicode-properties --enable-pcregrep-libz --enable-pcregrep-libbz2 --enable-pcre16 --enable-pcre32 --prefix=$PREFIX
make
make install

