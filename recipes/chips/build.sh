#!/bin/bash

export C_INCLUDE_PATH="$PREFIX/include"
export CPP_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include

export LIBRARY_PATH="$PREFIX/lib"
export CFLAGS="$CFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
export CPATH=${PREFIX}/include

mkdir build
cd build
cmake ..
make CC=$CC
