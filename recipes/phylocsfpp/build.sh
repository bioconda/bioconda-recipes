#!/bin/bash

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
export LD_LIBRARY_PATH=${PREFIX}/lib

CFLAGS="$CFLAGS -g -Wall -O3 -Wsign-compare -L$PREFIX/lib -I$PREFIX/include"

mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX="${PREFIX}" -DCMAKE_BUILD_TYPE=Release
make
make install
