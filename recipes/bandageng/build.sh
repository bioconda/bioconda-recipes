#!/bin/bash
set -ex

mkdir build && cd build
cmake \
    -DCMAKE_PREFIX_PATH=${PREFIX} \
    -DCMAKE_CXX_FLAGS="${CXXFLAGS} -std=c++17" \
    ..
make

# Install
mkdir $PREFIX/bin
cp Bandage $PREFIX/bin
