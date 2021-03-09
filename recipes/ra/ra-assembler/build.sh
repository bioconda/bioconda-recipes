#!/bin/bash

export CPATH=${PREFIX}/include

mkdir -p $PREFIX/bin
rm -rf build
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release ..
make
cp ./bin/ra $PREFIX/bin/ra
