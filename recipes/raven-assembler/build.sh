#!/bin/bash

mkdir -p $PREFIX/bin
rm -rf build
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$PREFIX -Dspoa_optimize_for_portability=ON ..
make
cmake --target install -DCMAKE_INSTALL_PREFIX=$PREFIX
