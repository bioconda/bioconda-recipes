#!/bin/bash

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

mkdir -p $PREFIX/bin
make
mv agg $PREFIX/bin
