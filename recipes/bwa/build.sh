#!/bin/bash

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

make
mkdir -p $PREFIX/bin
cp bwa $PREFIX/bin
cp xa2multi.pl $PREFIX/bin
cp qualfa2fq.pl $PREFIX/bin
