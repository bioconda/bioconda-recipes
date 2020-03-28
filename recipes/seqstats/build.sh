#!/bin/sh
make CC=$CC
mkdir -p $PREFIX/bin
cp seqstats $PREFIX/bin
