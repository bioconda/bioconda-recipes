#!/bin/bash
export LIBRARY_PATH=${PREFIX}/lib
export C_INCLUDE_PATH=${PREFIX}/include
cmake -H. -Bbuild
cmake --build build
mkdir -p $PREFIX/bin
mv build/bin/* $PREFIX/bin
