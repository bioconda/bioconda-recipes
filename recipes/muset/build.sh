#!/bin/bash
set -ex

# Create build directory
mkdir -p build && cd build

# CMake configuration (exactly as in original instructions)
cmake ..

# Build with parallel compilation
make -j4

# Install
make install
