#!/bin/bash

cd htslib*
make
cd ..

make pycd
#CFLAGS="${CFLAGS} -g -w -O3 -Wsign-compare "
mkdir -p $PREFIX/bin
cp bmtools $PREFIX/bin
cp bmDMR $PREFIX/bin
