#!/bin/bash

mkdir build
cd build
cmake \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DHDF5_ROOT="${PREFIX}/include" \
    ../src
make
make install
