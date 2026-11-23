#!/usr/bin/env bash
set -euo pipefail

cmake ${CMAKE_ARGS} \
    -S . -B build \
    -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DBGEN_BUILD_TESTS=ON \
    -DBGEN_WITH_S3=ON

cmake --build build --parallel "${CPU_COUNT}"

# Run unit tests; skip S3 integration test (requires live MinIO/S3)
ctest --test-dir build -E test_s3_bgen --output-on-failure

cmake --install build

