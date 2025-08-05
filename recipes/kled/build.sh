#!/bin/bash

set -euo pipefail

# Create build directory
mkdir -p build
cd build

# Configure with CMake
cmake \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CXX_STANDARD=17 \
    -DCMAKE_CXX_FLAGS="-O3 -fPIE" \
    "${SRC_DIR}"

# Build
make -j ${CPU_COUNT}

# Install
make install
