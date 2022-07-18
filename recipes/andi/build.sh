#!/bin/bash

mkdir -p $PREFIX/bin
export CFLAGS="$CFLAGS -std=c11"
export CFLAGS="$CFLAGS -D__STDC_NO_THREADS__=1"

./configure --prefix=$PREFIX 
make
make install
