#!/bin/bash

export CPP_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

cd gatb-core

rm -rf thirdparty/hdf5 thirdparty/boost

mkdir build
cd build

cmake -DCMAKE_INSTALL_PREFIX=$PREFIX ..
make
make install
