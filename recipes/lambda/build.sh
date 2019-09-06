#!/bin/bash

mkdir -p $PREFIX/bin
mkdir -p build
cd build
cmake ..
make
ls -l bin
cp bin/lambda2 $PREFIX/bin
