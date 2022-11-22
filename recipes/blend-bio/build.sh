#!/bin/bash

mkdir -p $PREFIX/bin

export CPATH=${PREFIX}/include
export CFLAGS="$CFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"

make CC=$CC INCLUDES="-I$PREFIX/include" CFLAGS="-g -Wall -O2 -Wc++-compat -L$PREFIX/lib" blend sdust
cp blend $PREFIX/bin
