#!/bin/bash
set -euo pipefail

cmake -S . -B build \
    ${CMAKE_ARGS} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_CXX_COMPILER="${CXX}" \
    -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
    -DCMAKE_EXE_LINKER_FLAGS="${LDFLAGS}" \
    -DBUILD_TESTING=OFF \
    -DHTSLIB_ROOT="${PREFIX}"
cmake --build build --parallel "${CPU_COUNT}"
cmake --install build
