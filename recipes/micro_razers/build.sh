#!/bin/bash

mkdir -p $PREFIX/bin
mkdir -p build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make micro_razers
cp bin/micro_razers $PREFIX/bin
