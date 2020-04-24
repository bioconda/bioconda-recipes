#!/bin/bash

mkdir -p $PREFIX/bin

make INCLUDE="-I$PREFIX/include" CFLAGS="-Wall -O3 -Wno-unused-variable -Wno-unused-function -Wno-misleading-indentation -I$PREFIX/include -L$PREFIX/lib"

cp bin/abpoa $PREFIX/bin
