#!/bin/bash

mkdir -p build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS="-mavx2"
make -j2

mkdir -p $PREFIX/bin
cp bin/raptor $PREFIX/bin
chmod +x $PREFIX/bin/raptor
