#!/usr/bin/env bash
set -euo pipefail

# atomic_flag::wait/notify_all require macOS 11.0; std::filesystem/aligned_alloc need 10.15
export MACOSX_DEPLOYMENT_TARGET="11.0"

mkdir -p build && cd build

cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_PREFIX_PATH="${PREFIX}" \
    -DTUNA_CONDA_PROFILE=ON \
    -DTUNA_USE_ZLIB_NG=OFF \
    -DCMAKE_CXX_FLAGS="-O3 -march=x86-64" \
    -DCMAKE_THREAD_PREFER_PTHREAD=ON \
    -DTHREADS_PREFER_PTHREAD_FLAG=ON \
    -DFETCHCONTENT_SOURCE_DIR_KFF_SRC="${SRC_DIR}/kff_src"

cmake --build . --target tuna -j"${CPU_COUNT}"

install -Dm755 tuna "${PREFIX}/bin/tuna"
