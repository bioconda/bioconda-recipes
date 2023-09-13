#!/bin/bash

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
make

mkdir -p $PREFIX/bin
cp src/ALE $PREFIX/bin
cp src/synthReadGen $PREFIX/bin
