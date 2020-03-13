#!/bin/bash
export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include

mkdir build
cd build

if [ `uname` == Darwin ]; then
    cmake -v \
        -D CMAKE_INSTALL_PREFIX:PATH=$PREFIX \
        -DIQTREE_FLAGS=omp \
        -DCMAKE_C_COMPILER=clang \
        -DCMAKE_CXX_COMPILER=clang++ \
        ..
else
    cmake -D CMAKE_INSTALL_PREFIX:PATH=$PREFIX -DIQTREE_FLAGS=omp ..
fi

make -j${CPU_COUNT}
make install
