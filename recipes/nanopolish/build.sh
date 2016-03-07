#!/bin/bash

mkdir -p $PREFIX/bin

CFLAGS="-I. -I${PREFIX}/include -L${PREFIX}/lib" PREFIX=${PREFIX} make
#make
cp nanopolish $PREFIX/bin



