#!/bin/bash
set -ex

mkdir build
cd build

cmake .. -DCMAKE_INSTALL_PREFIX="${PREFIX}"
make -j"${CPU_COUNT}"

mkdir -p "${PREFIX}/bin"
cp bin/alerax "${PREFIX}/bin/alerax"
chmod +x "${PREFIX}/bin/alerax"