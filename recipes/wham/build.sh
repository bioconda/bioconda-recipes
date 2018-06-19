#!/bin/bash
export CPPFLAGS="-I$PREFIX/include"
export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export LD_LIBRARY_PATH="$PREFIX/lib:$LD_LIBRARY_PATH"
export C_INCLUDE_PATH=${PREFIX}/include

make
mkdir -p $PREFIX/bin
cp bin/* $PREFIX/bin
