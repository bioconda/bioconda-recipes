#!/bin/bash

set -exo pipefail

export CFLAGS="${CFLAGS} -O3"
export CXXFLAGS="${CXXFLAGS} -O3"

# CMake設定
cmake -S . -B build -G Ninja \
    ${CMAKE_ARGS} \
    -DCMAKE_C_FLAGS="${CFLAGS}" \
    -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
    -DZLIB_ROOT="${PREFIX}"

cmake --build build --parallel ${CPU_COUNT}
cmake --install build

install -m 755 build/srsgen ${PREFIX}/bin/
install -m 755 build/srsview ${PREFIX}/bin/
