#!/bin/bash

mkdir -p $PREFIX/bin
mkdir -p build
cd build
cmake ../lambda
make
cp bin/lambda $PREFIX/bin
