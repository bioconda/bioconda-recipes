#!/bin/bash

export CPP_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
mkdir -p ${PREFIX}/bin

# create build directory
mkdir -p build
cd build

# compilation
cmake ..
make

# copy binaries
cp tools/lordec-* ${PREFIX}/bin
