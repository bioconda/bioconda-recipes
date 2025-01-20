#!/bin/bash
set -ex

# Create build directory
mkdir -p build && cd build

# CMake configuration
cmake .. \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCONDA_BUILD=ON \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CXX_STANDARD=17 \
    -DARCH_NATIVE=OFF

# Build with parallel compilation
make -j4

# Install
make install
