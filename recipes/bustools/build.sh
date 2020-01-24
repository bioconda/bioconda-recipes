#!/bin/bash

mkdir -p $PREFIX/bin
mkdir -p build 
cd build 
cmake -DCMAKE_INSTALL_PREFIX:PATH=$PREFIX ..
make 
make install