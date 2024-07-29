#!/bin/bash

mkdir -p build
cd build

cmake ${SRC_DIR} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DBUILD_SHARED_LIBS=ON \
    -DENABLE_TESTS=OFF \
    -DCMAKE_CXX_STANDARD=14 \
    -DCMAKE_VERBOSE_MAKEFILE=ON

make
make install
