#!/bin/bash
#mkdir -p $PREFIX/bin

#export CFLAGS="-I$PREFIX/include"
#export LDFLAGS="-L$PREFIX/lib"

make

cp bwa-mem2* $PREFIX/bin
