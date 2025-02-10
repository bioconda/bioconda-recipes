#!/bin/bash

cd $SRC_DIR/Code

cmake -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_CXX_COMPILER=${CXX} .
cmake --build .

mkdir -p $PREFIX/bin
cp -a $SRC_DIR/Code/. $PREFIX/bin

