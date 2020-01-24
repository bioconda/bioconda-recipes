#!/bin/bash

export GSL_INCLUDE_DIRS=${PREFIX}/include
export GSL_LIBRARY_DIRS=${PREFIX}/lib
export C_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include
export CPP_INCLUDE_PATH=${PREFIX}/include
export CPPLUS_INCLUDE_PATH=${PREFIX}/include
ls -l $PREFIX/include/gsl

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
