#!/bin/bash
set -euo pipefail

cmake -S . -B build \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_PREFIX_PATH="${PREFIX}" \
  -DPANISOGUARD_BUILD_TESTS=OFF

cmake --build build -j "${CPU_COUNT:-2}"
cmake --install build --prefix "${PREFIX}"
