#!/bin/sh

export CPPFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
make all prefix=${PREFIX} CC=${CC} LDFLAGS="$LDFLAGS" CFLAGS="$CFLAGS"
make install prefix=${PREFIX} CC=${CC} LDFLAGS="$LDFLAGS" CFLAGS="$CFLAGS"
