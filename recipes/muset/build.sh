#!/bin/bash
set -ex

# Print environment variables
env

# Print compiler version
$CXX --version

# Print CMake version
cmake --version

# Create build directory
mkdir build && cd build

# Run CMake with verbose output
cmake .. \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCONDA_BUILD=ON \
    -DCMAKE_BUILD_TYPE=Release \
    -DARCH_NATIVE=OFF \
    -DCMAKE_CXX_STANDARD=17 \
    -DCMAKE_CXX_STANDARD_REQUIRED=ON \
    -DCMAKE_VERBOSE_MAKEFILE=ON

# Print contents of build directory
echo "Contents of build directory:"
ls -R

# Build with verbose output
make VERBOSE=1

# Install
make install