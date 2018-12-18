#!/bin/bash

mkdir -p $PREFIX/bin

mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX 
make
make install
