#!/bin/bash

# ---- Exit on error ----
set -euo pipefail


# ---- Build and install ----
cp -rf ${RECIPE_DIR}/CMakeLists.txt $SRC_DIR/CMakeLists.txt
mkdir -p build
cd build

cmake -S $SRC_DIR -B . \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_PREFIX_PATH="${PREFIX}" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CXX_COMPILER="${CXX}" \
    -DTBB_DIR="${PREFIX}/lib/cmake/TBB" \
    ${CMAKE_ARGS} -Wno-dev

make -j$(nproc)
make install
