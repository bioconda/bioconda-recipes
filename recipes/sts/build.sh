#!/bin/bash

export CXXFLAGS="-std=c++11"
export INCLUDE_PATH=${PREFIX}/include
export GSL_INCLUDE_DIRS=${PREFIX}/include
export GSL_LIBRARY_DIRS=${PREFIX}/lib

mkdir -p build
cd build
cmake -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_CXX_COMPILER=$CXX \
      -DCMAKE_C_COMPILER=$CC \
      -DGSL_INCLUDE_DIRS=$PREFIX/include \
      ..
make
mkdir -p $PREFIX/bin
cp _build/release/bin/sts-online $PREFIX/bin
