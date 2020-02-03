#!/bin/bash
export LD_LIBRARY_PATH=${PREFIX}/lib
export LIBRARY_PATH=${PREFIX}/lib
export LD_LIBRARY_PATH=${PREFIX}/lib
export C_INCLUDE_PATH=${PREFIX}/include
cmake -H. -Bbuild
cmake --build build
mkdir -p $PREFIX/bin
mv bin/* $PREFIX/bin
mkdir -p $PREFIX/lib
mv lib/* $PREFIX/lib
