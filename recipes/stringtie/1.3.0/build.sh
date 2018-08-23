#!/bin/sh
export C_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

make release
mkdir -p $PREFIX/bin
mv stringtie $PREFIX/bin
