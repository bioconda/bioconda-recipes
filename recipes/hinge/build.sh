#!/bin/bash




mkdir -p $PREFIX/bin

mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_C_COMPILER=gcc -DCMAKE_CXX_COMPILER=g++
make
make install
