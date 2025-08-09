#!/usr/bin/env bash

set -exo pipefail

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

cmake -S . -B build -G Ninja \
    ${CMAKE_ARGS} \
    -DPython_EXECUTABLE="${PYTHON}" \
    -DOST_ROOT="${PREFIX}" \
    -DCXX_FLAGS="${CXXFLAGS}" \
    -DOPTIMIZE=ON \
    -DDISABLE_DOCUMENTATION=ON

cmake --build build --parallel "${CPU_COUNT}"
cmake --build build --target check --parallel 1
cmake --install build --parallel "${CPU_COUNT}"
