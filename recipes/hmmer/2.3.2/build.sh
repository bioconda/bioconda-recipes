#!/bin/sh

set -e -u -x

export CFLAGS=-I$PREFIX/include
export LDFLAGS=-L$PREFIX/lib

./configure --prefix=$PREFIX --enable-threads
make CC=${CC} CFLAGS=${CFLAGS}  LDFLAGS=${LDFLAGS}
make install
