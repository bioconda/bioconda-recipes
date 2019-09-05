#!/bin/bash

mkdir -p $PREFIX/bin
mkdir -p build
cd build
cmake ..
make
cp lambda $PREFIX/bin
cp lambda_indexer $PREFIX/bin
