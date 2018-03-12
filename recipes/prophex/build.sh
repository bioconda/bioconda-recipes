#!/bin/bash

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

git clone https://github.com/prophyle/prophex
cd prophex
make
mkdir -p $PREFIX/bin
cp prophex $PREFIX/bin
