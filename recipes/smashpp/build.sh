#!/bin/bash
set -euxo pipefail

cmake -S . -B build \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DSMASHPP_VERSION_OVERRIDE="${PKG_VERSION}"

cmake --build build --parallel "${CPU_COUNT:-1}" --config Release
cmake --install build --config Release
