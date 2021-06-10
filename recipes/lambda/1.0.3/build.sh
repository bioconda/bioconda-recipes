#!/bin/bash

mkdir -p "$PREFIX/bin"
mkdir -p build
cd build
cmake -DLAMBDA_NATIVE_BUILD=0 ..
make
cp bin/lambda "$PREFIX/bin/"
cp bin/lambda_indexer "$PREFIX/bin/"
