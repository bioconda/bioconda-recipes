#!/bin/sh
make CC=$CC

make
mkdir -p $PREFIX/bin
cp seqstats $PREFIX/bin
