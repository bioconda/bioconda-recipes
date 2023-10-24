#!/bin/bash

mkdir -p $PREFIX/bin

make INCLUDES="-I$PREFIX/include" CFLAGS="-g -Wall -O2 -L$PREFIX/lib"
cp yak $PREFIX/bin
