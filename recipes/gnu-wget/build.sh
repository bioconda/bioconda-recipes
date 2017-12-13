#!/bin/sh
set -euo pipefail

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include

./configure --prefix=$PREFIX        \
            --enable-threads=posix  \
            --with-ssl=openssl

make
make install
