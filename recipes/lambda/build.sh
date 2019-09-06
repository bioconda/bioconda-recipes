#!/bin/bash

mkdir -p $PREFIX/bin
mkdir -p build
cd build
cmake ..
make
ls -l bin
cp lambda2 $PREFIX/bin
cp lambda_indexer $PREFIX/bin
