#!/bin/bash

mkdir -p $PREFIX/bin
export CFLAGS="$CFLAGS -O3 -std=c11 -Wno-implicit-function-declaration -Wno-int-conversion"
export CFLAGS="$CFLAGS -D__STDC_NO_THREADS__=1"

./configure --prefix="$PREFIX"
make
make install
