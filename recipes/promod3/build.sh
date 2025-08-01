#!/usr/bin/env bash

set -exo pipefail

if [[ $(uname -m) == "x86_64" ]]; then
    export CMAKE_ARGS="${CMAKE_ARGS} -DENABLE_SSE=1"
else
    export CMAKE_ARGS="${CMAKE_ARGS} -DENABLE_SSE=0"
fi

if [[ "${target_platform}" == "linux-"* ]]; then
    export LDFLAGS="${LDFLAGS} -Wl,--allow-shlib-undefined,--export-dynamic"
elif [[ "${target_platform}" == "osx-"* ]]; then
    export LDFLAGS="${LDFLAGS} -undefined dynamic_lookup -Wl,-export_dynamic"
fi

mkdir -p build && cd build

cmake .. \
    ${CMAKE_ARGS} \
    -DCMAKE_PREFIX_PATH="${PREFIX}" \
    -DOST_ROOT="${PREFIX}" \
    -DCMAKE_CXX_COMPILER="${CXX}" \
    -DCXX_FLAGS="${CXXFLAGS}" \
    -DOPTIMIZE=ON \
    -DDISABLE_DOCUMENTATION=1

make -j"${CPU_COUNT}"

if [ "${CIRCLECI}" != "true" ]; then
    make check
fi

make install
cd "${SRC_DIR}" && rm -rf build
