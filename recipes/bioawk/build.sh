#!/bin/bash
export LIBRARY_PATH="$PREFIX/lib"

make CC=$CC CFLAGS="-g -Wall -O2 -I$PREFIX/include"

mkdir -p $PREFIX/bin
cp bioawk $PREFIX/bin
