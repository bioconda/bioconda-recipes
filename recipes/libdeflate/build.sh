#!/bin/bash

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

make
mkdir -p $PREFIX/bin
cp libdeflate.so $PREFIX/lib/
cp libdeflate.h $PREFIX/include/
