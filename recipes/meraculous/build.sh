#!/bin/bash

mkdir -p $PREFIX/bin

cd Meraculous-v$PKG_VERSION

mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX 
make
make install
