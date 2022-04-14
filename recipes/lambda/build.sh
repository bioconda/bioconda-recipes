#!/bin/bash

mkdir -p "$PREFIX/bin"
mkdir -p build
cd build
cmake -DLAMBDA_NATIVE_BUILD=0 ..
make
cp bin/lambda2 "$PREFIX/bin/"
