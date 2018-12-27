#!/bin/bash

mkdir -p $PREFIX/bin
git submodule init
git submodule update
export C_INCLUDE_PATH=$PREFIX/include
export LIBRARY_PATH=$PREFIX/lib
make
cp src/matlock $PREFIX/bin
