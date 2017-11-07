#!/bin/bash

mkdir -p $PREFIX/bin
mkdir -p build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_BUILD_TYPE=Release

make seqan_tcoffee
make install
#cp bin/seqan_tcoffee $PREFIX/bin
