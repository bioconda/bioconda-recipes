#!/bin/bash
set -euo pipefail

cmake -S . -B build \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DCMAKE_PREFIX_PATH="${PREFIX}" \
  -DHTSLIB_ROOT="${PREFIX}" \
  -DUSE_ISAL=off \
  -DFALCO_TESTS=off

cmake --build build -j"${CPU_COUNT}"
cmake --install build
