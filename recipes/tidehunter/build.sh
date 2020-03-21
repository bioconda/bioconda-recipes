#!/bin/bash

mkdir -p $PREFIX/bin

make INCLUDE="-I$PREFIX/include" CFLAGS="-Wall -O3 -Wno-unused-variable -Wno-unused-function -Wno-misleading-indentation -L$PREFIX/lib"

cp bin/TideHunter $PREFIX/bin
