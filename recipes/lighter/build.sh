#!/bin/sh

export C_INCLUDE_PATH=$PREFIX/include
export CPLUS_INCLUDE_PATH=$PREFIX/include
export CFLAGS="-I$PREFIX/include"

mkdir -p $PREXIX/bin
make
cp lighter $PREFIX/bin

