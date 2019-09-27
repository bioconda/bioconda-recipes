#!/bin/bash

mkdir -p $PREFIX/bin
export LIBRARY_PATH=${PREFIX}/lib
export CPP_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include

mkdir build && cd build
cmake ../src -DCMAKE_INSTALL_PREFIX=$PREFIX  -DHDF5_ROOT=$PREFIX/include
make
make install
