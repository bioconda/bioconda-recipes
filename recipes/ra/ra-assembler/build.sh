#!/bin/bash

mkdir -p $PREFIX/bin
rm -rf build
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release ..
conda activate
make
cp ./bin/ra $PREFIX/bin/ra
