#!/bin/bash
set -ex

# Initialize and update git submodules (for minimap2)
git submodule update --init --recursive || true

mkdir -p build
cd build

cmake .. \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_BUILD_TYPE=Release \
    -DEASTR_BUILD_TESTS=OFF

make -j${CPU_COUNT}
make install
