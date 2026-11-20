#!/bin/bash
set -euo pipefail

cmake -S . -B build \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DCMAKE_CXX_COMPILER="${CXX}" \
  -DCMAKE_C_COMPILER="${CC}"

cmake --build build -j "${CPU_COUNT}"
cmake --install build
