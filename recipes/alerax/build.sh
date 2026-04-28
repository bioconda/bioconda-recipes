#!/bin/bash
set -ex

# Fix CMakeLists.txt - comment out missing ext subdirectory
sed -i 's/add_subdirectory(ext)/#add_subdirectory(ext)/g' CMakeLists.txt

mkdir -p build
cd build

cmake .. -DCMAKE_INSTALL_PREFIX="${PREFIX}" -DCMAKE_BUILD_TYPE=Release
make -j"${CPU_COUNT}"

mkdir -p "${PREFIX}/bin"
cp bin/alerax "${PREFIX}/bin/alerax"
chmod +x "${PREFIX}/bin/alerax"