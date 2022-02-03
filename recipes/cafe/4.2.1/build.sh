#!/bin/bash

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

./configure

make
mkdir -p $PREFIX/bin
cp release/cafe $PREFIX/bin
