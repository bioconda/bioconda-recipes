#!/bin/bash
set -ex

# Print compiler paths
which cmake
which $CC
which $CXX
# Initialize and update submodules if needed
git submodule update --init --recursive

# Create build directory
mkdir -p build && cd build

# Detailed CMake configuration
cmake .. \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CXX_STANDARD=17 \
    -DCMAKE_C_COMPILER=$CC \
    -DCMAKE_CXX_COMPILER=$CXX

# Build the project
make -j4

# Install
make install
