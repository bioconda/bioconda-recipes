#!/bin/bash

cd sctools
mkdir -p build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make
mkdir -p $PREFIX/bin
cp apps/sctools $PREFIX/bin
