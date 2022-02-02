#!/bin/bash

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

cd libs/phylogeny
make CC=$CXX

cd ../../programs/gainLoss
make CC=$CXX

mkdir -p $PREFIX/bin
cp gainLoss $PREFIX/bin
