#!/bin/bash

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
mkdir -p $PREFIX/bin

make CC="${CC}" CFLAGS="${CFLAGS}" CPPFLAGS="{CPPFLAGS}"
mv bfc  $PREFIX/bin

