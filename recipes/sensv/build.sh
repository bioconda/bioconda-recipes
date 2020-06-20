#!/bin/bash

mkdir -pv $PREFIX/bin

cp -rv src modules data $PREFIX/bin
cp Makefile sensv *.ini $PREFIX/bin/

cd $PREFIX/bin/ && make CC=$CC INCLUDES="-I$PREFIX/include" CFLAGS="-g -Wall -O2 -Wc++-compat -L$PREFIX/lib" && cd -
