#!/bin/bash

mkdir -p $PREFIX/bin
make INCLUDE="-I$PREFIX/include" CFLAGS="-Wall -Wno-unused-variable -Wno-unused-function -Wno-misleading-indentation -I$PREFIX/include -L$PREFIX/lib -fopenmp"

