#!/bin/bash

mkdir -p $PREFIX/bin
rm -rf build
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release -DRAVEN_BUILD_EXE=ON -DCMAKE_INSTALL_PREFIX=$PREFIX -Dspoa_optimize_for_portability=ON ..
make
cp bin/raven $PREFIX/bin
