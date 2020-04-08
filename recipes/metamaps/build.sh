#!/bin/bash

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

./bootstrap.sh
./configure --with-boost=/path/to/boost --prefix=${PREFIX}
make metamaps

mkdir -p $PREFIX/bin
cp -f metamaps $PREFIX/bin/
