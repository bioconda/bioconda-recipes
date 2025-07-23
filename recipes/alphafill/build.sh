#!/bin/bash

set -exo pipefail

export CXXFLAGS="${CXXFLAGS} -O3"

if [[ "${target_platform}" == "linux-aarch64" ]]; then
  export CXXFLAGS="${CXXFLAGS} -march=armv8-a"
elif [[ "${target_platform}" == "osx-arm64" ]]; then
  export CXXFLAGS="${CXXFLAGS} -march=armv8.4-a"
else
  export CXXFLAGS="${CXXFLAGS} -march=x86-64-v3"
fi

if [[ "${target_platform}" == "linux-"* ]]; then
    cmake -S . -B build -G Ninja \
        ${CMAKE_ARGS} \
        -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
        -DBUILD_WEB_APPLICATION=ON \
        -DALPHAFILL_DATA_DIR="${PREFIX}/share/alphafill" \
        -DBUILD_TESTING=ON
elif [[ "${target_platform}" == "osx-"* ]]; then
    cmake -S . -B build -G Ninja \
        ${CMAKE_ARGS} \
        -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
        -DBUILD_WEB_APPLICATION=OFF \
        -DALPHAFILL_DATA_DIR="${PREFIX}/share/alphafill" \
        -DBUILD_TESTING=ON
fi

cmake --build build --parallel "${CPU_COUNT}"
ctest -V -C Release --test-dir build
cmake --install build
