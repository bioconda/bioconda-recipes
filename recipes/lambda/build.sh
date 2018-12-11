#!/bin/bash

mkdir -p $PREFIX/bin
mkdir -p build
cd build
cmake ..
make
cp bin/lambda $PREFIX/bin
