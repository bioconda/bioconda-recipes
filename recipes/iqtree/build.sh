#!/bin/bash
export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include

if [ "$(uname)" == Darwin ]; then
    export CMAKE_C_COMPILER="clang"
    export CMAKE_CXX_COMPILER="clang++"
fi

mkdir build
cd build

cmake -D CMAKE_INSTALL_PREFIX:PATH="${PREFIX}" -DIQTREE_FLAGS=omp ..

make --jobs "${CPU_COUNT}"
make install
