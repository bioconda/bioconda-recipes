#!/bin/bash

mkdir -p $PREFIX/bin
mkdir -p build
cd build
cmake ..
make
cp bin/lambda2 $PREFIX/bin
