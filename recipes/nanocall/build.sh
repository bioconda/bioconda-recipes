#!/bin/bash

mkdir -p $PREFIX/bin

mkdir build && cd build
cmake ../src -DCMAKE_INSTALL_PREFIX=$PREFIX  -DHDF5_ROOT=$PREFIX/include
make
make install
