#!/bin/bash

set -exo pipefail

export CXXFLAGS="${CXXFLAGS} -O3"

sed -i.bak 's|if (NOT TARGET dssp)|find_package(dssp QUIET)\nif(NOT TARGET dssp::dssp AND NOT TARGET dssp)|g' CMakeLists.txt
sed -i.bak 's|${CIFPP_SHARE_DIR}|$ENV{PREFIX}/share/libcifpp|g' CMakeLists.txt

cmake -S . -B build -G Ninja \
    ${CMAKE_ARGS} \
    -DCMAKE_CXX_STANDARD=20 \
    -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
    -DBUILD_TESTING=ON \
    -DCIFPP_SHARE_DIR="${PREFIX}/share/libcifpp"

cmake --build build --config Release --parallel "${CPU_COUNT}"
ctest -V -C Release --test-dir build
cmake --install build
