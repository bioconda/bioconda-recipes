#!/bin/bash
mkdir build
cd build

cmake -D CMAKE_INSTALL_PREFIX:PATH=$PREFIX -DIQTREE_FLAGS=omp ..
make
make install

