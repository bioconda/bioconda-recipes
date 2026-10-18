#!/bin/bash -euo pipefail

export CFLAGS="${CFLAGS} -fcommon"
export CXXFLAGS="${CXXFLAGS} -fcommon"

cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
  -DCONDA_BUILD=TRUE \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DCMAKE_CXX_COMPILER="${CXX}" \
  -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
  -DCMAKE_C_COMPILER="${CC}" \
  -DCMAKE_C_FLAGS="${CFLAGS}" \
  -Wno-dev -Wno-deprecated --no-warn-unused-cli

cmake --build build --clean-first --target install -j "${CPU_COUNT}"
