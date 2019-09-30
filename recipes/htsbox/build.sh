#!/bin/bash

#strictly use anaconda build environment
export CFLAGS="${CFLAGS} -L${PREFIX}/lib
export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

mkdir -p $PREFIX/bin

make CC=${CC} CFLAGS="${CFLAGS}"
mv htsbox  $PREFIX/bin

