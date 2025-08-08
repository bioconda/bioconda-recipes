#!/usr/bin/env bash

set -exo pipefail

export CXXFLAGS="${CXXFLAGS} -O3"

if [[ $(uname -m) == "x86_64" ]]; then
    export CMAKE_ARGS="${CMAKE_ARGS} -DENABLE_SSE=ON"
else
    export CMAKE_ARGS="${CMAKE_ARGS} -DENABLE_SSE=OFF"
fi

if [[ "${target_platform}" == "linux-"* ]]; then
    export LDFLAGS="${LDFLAGS} -Wl,--allow-shlib-undefined,--export-dynamic"
elif [[ "${target_platform}" == "osx-"* ]]; then
    export LDFLAGS="${LDFLAGS} -undefined dynamic_lookup -Wl,-export_dynamic"
fi

sed -i.bak \
    -e 's|lib64|lib|g' \
    -e 's|set(CMAKE_CXX_STANDARD 17)|set(CMAKE_CXX_STANDARD 11)|' \
    cmake_support/PROMOD3.cmake

cmake -S . -B build -G Ninja \
    ${CMAKE_ARGS} \
    -DPython_EXECUTABLE="${PYTHON}" \
    -DOST_ROOT="${PREFIX}" \
    -DCXX_FLAGS="${CXXFLAGS}" \
    -DOPTIMIZE=ON \
    -DDISABLE_DOCUMENTATION=ON

cmake --build build --clean-first -j "${CPU_COUNT}"
cmake --install build -j "${CPU_COUNT}"
