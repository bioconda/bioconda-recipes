#!/bin/bash

mkdir build
cd build
cmake \
    -DBoost_USE_STATIC_LIBS=OFF \
    -DCOMPILER_FLAGS= \
..
make -j"${CPU_COUNT}"

install -d "${PREFIX}/bin"
install haploflow "${PREFIX}/bin/"
