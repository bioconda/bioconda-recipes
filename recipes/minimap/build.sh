#!/bin/bash

mkdir -p $PREFIX/bin

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
make 
make extra 

cp minimap $PREFIX/bin 
cp minimap-lite $PREFIX/bin
cp sdust $PREFIX/bin
  
