#!/bin/bash
set -euo pipefail

mkdir -p build
cd build

cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_PREFIX_PATH="${PREFIX}"

make -j"${CPU_COUNT}"

# Install binary
install -m 755 dart "${PREFIX}/bin/dart"
