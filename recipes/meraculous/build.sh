#!/bin/bash

set -xe

mkdir build
cd build
cmake \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DBUILD_SHARED_LIBS=ON \
    ..
make -j ${CPU_COUNT}
make install
