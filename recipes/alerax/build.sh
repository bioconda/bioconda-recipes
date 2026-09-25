#!/bin/bash
set -euxo pipefail

mkdir -p build
cd build

cmake ${CMAKE_ARGS} .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}"

make -j"${CPU_COUNT}" alerax

mkdir -p "${PREFIX}/bin"
cp bin/alerax "${PREFIX}/bin/alerax"
chmod +x "${PREFIX}/bin/alerax"