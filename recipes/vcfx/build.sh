#!/bin/bash
set -e

mkdir -p build
cd build

# Configure
cmake ${CMAKE_ARGS} \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_PREFIX_PATH=${PREFIX} \
    -DCMAKE_BUILD_TYPE=Release \
    ..

# Build with specified number of cores
make -j${CPU_COUNT}


# Install
make install 