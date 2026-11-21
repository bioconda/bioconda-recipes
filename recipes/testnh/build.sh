#!/bin/bash
set -euxo pipefail

# testnh v3.0.0 requests bpp-phyl "3.0.0" (the Bio++ release number), but
# bpp-phyl's CMake config reports its library version (13.0.0 for Bio++ 3.0.0).
# Request the library version instead, as bppsuite does.
sed -i.bak 's/find_package(bpp-phyl 3.0.0 REQUIRED)/find_package(bpp-phyl 13.0.0 REQUIRED)/' CMakeLists.txt

mkdir -p build
cd build

cmake ${CMAKE_ARGS} \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_PREFIX_PATH="${PREFIX}" \
    -DCMAKE_INSTALL_RPATH="${PREFIX}/lib" \
    -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DCMAKE_BUILD_TYPE=Release \
    ..

make -j 4
make install