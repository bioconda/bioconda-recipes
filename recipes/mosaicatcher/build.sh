#!/bin/bash

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

mkdir build
cd build
cmake ../src \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_PREFIX_PATH=${PREFIX} \
    \
    -DCMAKE_CXX_LINK_FLAGS="${LDFLAGS}" \
    -DCMAKE_EXE_LINKER_FLAGS="${LDFLAGS}" \
    -DCMAKE_CXX_FLAGS="${CXXFLAGS}"

make

mkdir -p "$PREFIX"/bin
cp mosaicatcher "$PREFIX"/bin/mosaicatcher
