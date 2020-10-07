#!/bin/bash
export C_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
mkdir -p $PREFIX/bin
make release
cp stringtie $PREFIX/bin
