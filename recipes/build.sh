#!/bin/bash

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

cd libs/phylogeny
make

cd ../../programs/gainLoss
make

mkdir -p $PREFIX/bin
cp gainLoss $PREFIX/bin
