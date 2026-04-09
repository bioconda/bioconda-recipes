#!/bin/bash
set -ex

cmake -S . -B build \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_CXX_COMPILER="${CXX}" \
    -DCMAKE_C_COMPILER="${CC}" \
    -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
    -DCMAKE_C_FLAGS="${CFLAGS}" \
    -DRESEQ_BUILD_TESTS=OFF \
    -DRESEQ_BUILD_PYTHON=OFF

cmake --build build -j "${CPU_COUNT}"
cmake --install build
