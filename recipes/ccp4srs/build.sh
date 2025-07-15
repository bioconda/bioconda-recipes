#!/bin/bash

set -exo pipefail

export CFLAGS="${CFLAGS} -O3"
export CXXFLAGS="${CXXFLAGS} -O3"

sed -i.bak 's|find_package(zlib REQUIRED)|find_package(ZLIB REQUIRED)|' CMakeLists.txt

cmake -S . -B build -G Ninja \
    ${CMAKE_ARGS} \
    -DCMAKE_C_FLAGS="${CFLAGS}" \
    -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5
cmake --build build --parallel "${CPU_COUNT}"
cmake --install build

install -m 755 build/srsgen "${PREFIX}/bin/"
install -m 755 build/srsview "${PREFIX}/bin/"
