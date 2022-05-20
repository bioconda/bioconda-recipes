#!/bin/bash

mkdir build
cd build

cmake \
    -DINSTANCE_COUNT=64 \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCONDA_BUILD=ON \
    ..
make install
