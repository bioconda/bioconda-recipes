#!/bin/bash

mkdir -p build
cd build

cmake ${SRC_DIR} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_INSTALL_LIBDIR=${PREFIX}/lib \
    -DBUILD_SHARED_LIBS=ON \
    -DENABLE_TESTS=OFF \
    -DCMAKE_VERBOSE_MAKEFILE=ON

make
make install
