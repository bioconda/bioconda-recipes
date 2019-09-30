#!/bin/bash

#strictly use anaconda build environment
export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

mkdir -p $PREFIX/bin

make CC=${CC}
mv htsbox  $PREFIX/bin

