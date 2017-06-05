#!/bin/sh
rm findpath.h	#Already included in ViennaRNA
make clean
make all
cp kinwalker $PREFIX/bin
