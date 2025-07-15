#!/bin/bash

set -exo pipefail

export CXXFLAGS="${CXXFLAGS} -O3"

cp -fv ${SRC_DIR}/rsrc/torsion-data.bin ${PREFIX}/share/libcifpp/
cp -fv ${SRC_DIR}/rsrc/rama-data.bin ${PREFIX}/share/libcifpp/

sed -i.bak 's|if (NOT TARGET dssp)|find_package(dssp QUIET)\nif(NOT TARGET dssp::dssp AND NOT TARGET dssp)|g' CMakeLists.txt

cmake -S . -B build -G Ninja \
    ${CMAKE_ARGS} \
    -DCMAKE_CXX_STANDARD=20 \
    -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
    -DBUILD_TESTING=ON \
    -DCIFPP_SHARE_DIR="${PREFIX}/share/libcifpp"

cmake --build build --config Release --parallel "${CPU_COUNT}"
ctest -V -C Release --test-dir build
cmake --install build

