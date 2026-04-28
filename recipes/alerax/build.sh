#!/bin/bash
set -ex

git submodule update --init --recursive

mkdir -p build
cd build

cmake .. -DCMAKE_INSTALL_PREFIX="${PREFIX}" -DCMAKE_BUILD_TYPE=Release
make -j"${CPU_COUNT}"

mkdir -p "${PREFIX}/bin"
cp bin/alerax "${PREFIX}/bin/alerax"
chmod +x "${PREFIX}/bin/alerax"