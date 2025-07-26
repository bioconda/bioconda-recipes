#!/usr/bin/env bash

set -exo pipefail

# Prevent build failures due to insufficient memory in the CI environment
# Use parallel build because of serial build on osx-arm64 causing occasional errors
if [[ "${build_platform}" == "linux-aarch64" || "${build_platform}" == "osx-arm64" ]]; then
  export CPU_COUNT=$(( CPU_COUNT * 70 / 100 ))
fi
if [[ $(uname -m) == "x86_64" ]]; then
    export CMAKE_ARGS="${CMAKE_ARGS} -DENABLE_SSE=1"
else
    export CMAKE_ARGS="${CMAKE_ARGS} -DENABLE_SSE=0"
fi

if [[ "${target_platform}" == "linux-"* ]]; then
    export LDFLAGS="${LDFLAGS} -Wl,--allow-shlib-undefined,--export-dynamic"
elif [[ "${target_platform}" == "osx-"* ]]; then
    export LDFLAGS="${LDFLAGS} -undefined dynamic_lookup -Wl,-export_dynamic -framework OpenGL"
fi

mkdir -p build && cd build

cmake .. \
    ${CMAKE_ARGS} \
    -DCMAKE_PREFIX_PATH="${PREFIX}" \
    -DOST_ROOT="${PREFIX}" \
    -DCMAKE_CXX_COMPILER="${CXX}" \
    -DCXX_FLAGS="${CXXFLAGS}" \
    -DCMAKE_CXX_STANDARD=11 \
    -DOPTIMIZE=ON \
    -DDISABLE_DOCUMENTATION=1 \
    -DCMAKE_VERBOSE_MAKEFILE=ON

make VERBOSE=1 -j"${CPU_COUNT}"

make check

make install
cd "${SRC_DIR}" && rm -rf build
