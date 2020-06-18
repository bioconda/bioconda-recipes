#!/bin/bash

mkdir -p $PREFIX/bin
mkdir -p build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make razers3
cp bin/razers3 $PREFIX/bin
