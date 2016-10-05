#!/bin/sh

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

./configure --prefix=$PREFIX        \
            --enable-threads=posix  \
            --with-ssl=openssl

make
make install
