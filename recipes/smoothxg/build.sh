#!/bin/bash
export LIBRARY_PATH=${PREFIX}/lib
export C_INCLUDE_PATH=${PREFIX}/include
cmake -H. -Bbuild -DCMAKE_BUILD_TYPE=Generic
cmake --build build
mkdir -p $PREFIX/bin
mv bin/* $PREFIX/bin
