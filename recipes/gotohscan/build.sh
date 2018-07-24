#!/bin/sh

export CFLAGS="-I$PREFIX/include -L$PREFIX/lib"

make
cp GotohScan $PREFIX/bin
