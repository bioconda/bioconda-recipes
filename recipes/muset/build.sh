#!/bin/bash
set -ex

# Print environment and build information
echo "Build Environment:"
env | grep -E "PREFIX|CC|CXX"

echo "Compiler Versions:"
$CC --version
$CXX --version
cmake --version

# Create and navigate to build directory
mkdir -p build && cd build

# Configure with CMake
cmake .. \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CXX_STANDARD=17

# Build the project
make -j4

# Install the binary
make install

# Verify installation
muset --help
