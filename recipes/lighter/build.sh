#!/bin/sh

export CPLUS_INCLUDE_PATH=$PREFIX/include

mkdir -p $PREXIX/bin
make
cp lighter $PREFIX/bin

