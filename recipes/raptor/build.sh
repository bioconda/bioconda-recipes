#!/bin/bash

mkdir -p build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS="-mavx2" -DRAPTOR_NATIVE_BUILD=OFF
make -j"${CPU_COUNT}"

mkdir -p $PREFIX/bin
cp bin/raptor $PREFIX/bin
chmod +x $PREFIX/bin/raptor
