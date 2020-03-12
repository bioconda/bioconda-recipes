#!/bin/bash
export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include

mkdir build
cd build

cmake -D CMAKE_INSTALL_PREFIX:PATH=$PREFIX -DIQTREE_FLAGS=omp ..
make -j${CPU_COUNT}
make install
