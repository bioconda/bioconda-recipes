#!/bin/bash

make INCLUDES="-I$PREFIX/include" CFLAGS="-L$PREFIX/lib"
mkdir -p $PREFIX/bin
cp gfatools $PREFIX/bin
