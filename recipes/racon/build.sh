#!/bin/bash

mkdir -p $PREFIX/bin
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${PREFIX} -Dracon_build_wrapper=ON ..
make
make install
cp bin/racon_wrapper ${PREFIX}/bin
