#!/bin/bash
set -euxo pipefail

if [[ "${target_platform:-}" == osx-* || "$(uname)" == "Darwin" ]]; then
    export CXXFLAGS="${CXXFLAGS:-} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

cmake -S . -B build \
    ${CMAKE_ARGS:-} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DSMASHPP_VERSION_OVERRIDE="${PKG_VERSION}"

cmake --build build --parallel "${CPU_COUNT:-1}" --config Release
cmake --install build --config Release
