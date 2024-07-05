#!/bin/bash

set -xe

mkdir build
cd build
cmake \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DHDF5_ROOT="${PREFIX}/include" \
    ../src
make -j ${CPU_COUNT}
make install
