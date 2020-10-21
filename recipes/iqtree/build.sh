#!/bin/bash
export CFLAGS="$CFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
export CPATH=${PREFIX}/include

if [ "$(uname)" == Darwin ]; then
    export MACOSX_DEPLOYMENT_TARGET=10.9
    export CMAKE_C_COMPILER="clang"
    export CMAKE_CXX_COMPILER="clang++"
fi

mkdir build
cd build

$BUILD_PREFIX/bin/cmake -D CMAKE_INSTALL_PREFIX:PATH=$PREFIX -DIQTREE_FLAGS=omp ..

make --jobs "${CPU_COUNT}"
make install
