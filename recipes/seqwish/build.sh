#!/bin/bash

set -xe

export LIBRARY_PATH=${PREFIX}/lib
export LD_LIBRARY_PATH=${PREFIX}/lib
export CPATH=${PREFIX}/include
export C_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export CPP_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include

EXTRA_FLAGS="-Ofast"

case $(uname -m) in
    x86_64)
        EXTRA_FLAGS="${EXTRA_FLAGS} -march=sandybridge"
        ;;
    *) ;;
esac

cmake -H. -Bbuild -DCMAKE_BUILD_TYPE=Generic -DEXTRA_FLAGS="${EXTRA_FLAGS}"
cmake --build build -j ${CPU_COUNT}
mkdir -p $PREFIX/bin
mv bin/* $PREFIX/bin
