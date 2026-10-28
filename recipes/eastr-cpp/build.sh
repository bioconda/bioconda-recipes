#!/bin/bash
set -ex

mkdir -p build
cd build

cmake .. \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_BUILD_TYPE=Release \
    -DEASTR_BUILD_TESTS=OFF \
    -DCMAKE_POLICY_DEFAULT_CMP0148=OLD

make -j${CPU_COUNT}
make install
