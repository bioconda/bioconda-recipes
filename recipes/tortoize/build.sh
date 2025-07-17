#!/bin/bash

set -exo pipefail

export CXXFLAGS="${CXXFLAGS} -O3"

sed -i.bak 's|if (NOT TARGET dssp)|find_package(dssp QUIET)\nif(NOT TARGET dssp::dssp AND NOT TARGET dssp)|g' CMakeLists.txt
sed -i.bak 's|${CIFPP_SHARE_DIR}|$ENV{PREFIX}/share/libcifpp|g' CMakeLists.txt

if [[ "${target_platform}" == "linux-"* ]]; then
    cmake -S . -B build -G Ninja \
        ${CMAKE_ARGS} \
        -DCMAKE_PREFIX_PATH="${PREFIX}" \
        -DCMAKE_CXX_STANDARD=20 \
        -DBUILD_TESTING=ON \
        -DBUILD_WEBSERVICE=ON \
        -DUSE_RSRC=ON \
        -DCIFPP_SHARE_DIR="${PREFIX}/share/libcifpp" \
        -Dzeep_DIR="${PREFIX}/lib/cmake/zeep"
elif [[ "${target_platform}" == "osx-"* ]]; then
    cmake -S . -B build -G Ninja \
        ${CMAKE_ARGS} \
        -DCMAKE_PREFIX_PATH="${PREFIX}" \
        -DCMAKE_CXX_STANDARD=20 \
        -DBUILD_TESTING=ON \
        -DCIFPP_SHARE_DIR="${PREFIX}/share/libcifpp"
fi

cmake --build build --config Release --parallel "${CPU_COUNT}"
ctest -V -C Release --test-dir build
cmake --install build
