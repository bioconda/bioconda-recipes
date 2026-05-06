#!/usr/bin/env bash
set -euo pipefail

mkdir -p build && cd build

cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_PREFIX_PATH="${PREFIX}" \
    -DTUNA_CONDA_PROFILE=ON \
    -DTUNA_USE_ZLIB_NG=OFF \
    -DCMAKE_CXX_FLAGS="-O3 -march=x86-64" \
    -DCMAKE_THREAD_PREFER_PTHREAD=ON \
    -DTHREADS_PREFER_PTHREAD_FLAG=ON

cmake --build . --target tuna -j"${CPU_COUNT}"

install -Dm755 tuna "${PREFIX}/bin/tuna"
