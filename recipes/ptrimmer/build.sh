#!/bin/sh

make CC=$CC LIBDIR=-L$PREFIX/lib INCLUDE=-I$PREFIX/include
mkdir -p $PREFIX/bin
mv pTrimmer-* $PREFIX/bin/ptrimmer