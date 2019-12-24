#!/bin/bash
echo "selectFasta compilation"
export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

make
mkdir -p $PREFIX/bin
cp selectFasta $PREFIX/bin
echo "Installation successful"
selectFasta -h
