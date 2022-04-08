#!/bin/bash

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

make CFLAGS="${CFLAGS} -fcommon"
mkdir -p $PREFIX/bin
mkdir -p $PREFIX/share/man/man1
cp bwa $PREFIX/bin
cp xa2multi.pl $PREFIX/bin
cp qualfa2fq.pl $PREFIX/bin
cp bwa.1 $PREFIX/share/man/man1
