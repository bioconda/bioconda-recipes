#!/bin/bash

#strictly use anaconda build environment
CC=${PREFIX}/bin/gcc
CXX=${PREFIX}/bin/g++

mkdir -p $PREFIX/bin

cd $SRC_DIR/build 

cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} ..
make

#mv exe/* $PREFIX/bin


