#!/bin/bash

mkdir -p build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS="-mavx2"
make -j"${CPU_COUNT}"

mkdir -p $PREFIX/bin
cp bin/needle $PREFIX/bin
chmod +x $PREFIX/bin/needle
