#!/bin/bash

mkdir -p $PREFIX/bin
export CPP_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include
export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

./autogen.sh
./configure --prefix=$PREFIX --with-sparsehash=$PREFIX
make
make install
