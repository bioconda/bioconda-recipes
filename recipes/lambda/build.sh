#!/bin/bash

mkdir -p $PREFIX/bin
mkdir -p build
cd build
cmake ..
make
cp bin/lambda $PREFIX/bin
cp bin/lambda_indexer $PREFIX/bin
