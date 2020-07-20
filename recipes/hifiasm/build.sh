#!/bin/bash

mkdir -p $PREFIX/bin

make INCLUDES="-I$PREFIX/include" CFLAGS="-L$PREFIX/lib"
cp hifiasm $PREFIX/bin
