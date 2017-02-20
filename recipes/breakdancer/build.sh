#!/bin/sh

mkdir build
cd build

cmake \
    -D CMAKE_BUILD_TYPE=release \
    -D CMAKE_INSTALL_PREFIX=${PREFIX} \
    ..

make
make install
