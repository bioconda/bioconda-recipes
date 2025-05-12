#!/usr/bin/env bash
set -euo pipefail

# create and enter build directory
mkdir -p build
cd build

# configure CMake: install into $PREFIX
cmake -DCMAKE_INSTALL_PREFIX="${PREFIX}" -DCMAKE_BUILD_TYPE=Release ..

# build and install
cmake --build .
cmake --install . --prefix "${PREFIX}"
#super lazy local fix
cd ../
cp ./build/rad "${PREFIX}/bin/rad"