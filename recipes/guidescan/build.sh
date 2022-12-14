#!/bin/bash

mkdir -p $PREFIX/bin

mkdir -p build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release

make
cp bin/guidescan $PREFIX/bin
chmod +x $PREFIX/bin/guidescan
