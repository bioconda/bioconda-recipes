#!/bin/bash

LDFLAGS="$LDFLAGS -L$PREFIX/lib"
CFLAGS="$CFLAGS -Wall -pedantic -I$PREFIX/include -DVERSION=$PKG_VERSION"

make CC=cc CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS" -j$CPU_COUNT
mkdir -p $PREFIX/bin
cp sickle $PREFIX/bin
