#!/bin/bash

mkdir -p $PREFIX/bin
export CFLAGS="$CFLAGS -std=c11"

./configure --prefix=$PREFIX 
make
make install
