#!/bin/bash

mkdir -p "$PREFIX/bin"

export CPP_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
make -j
cp bin/filtlong $PREFIX/bin
