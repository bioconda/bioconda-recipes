#!/bin/bash

# export C_INCLUDE_PATH="$PREFIX/include"
# export LIBRARY_PATH="$PREFIX/lib"
export CFLAGS="$CFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"

mkdir build
cd build
cmake ..
make CC=$CC
