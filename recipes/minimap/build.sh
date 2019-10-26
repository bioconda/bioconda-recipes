#!/bin/bash

mkdir -p $PREFIX/bin

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
make CC=$CC
make extra CC=$CC

cp minimap $PREFIX/bin 
cp minimap-lite $PREFIX/bin
cp sdust $PREFIX/bin
  
