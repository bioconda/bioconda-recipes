#!/bin/bash

set -exo pipefail

export CXXFLAGS="${CXXFLAGS} -O3"

sed -i.bak 's|if (NOT TARGET dssp)|find_package(dssp QUIET)\nif(NOT TARGET dssp::dssp AND NOT TARGET dssp)|g' CMakeLists.txt

if [[ "${target_platform}" == "linux-"* ]]; then
    cmake -S . -B build -G Ninja \
        ${CMAKE_ARGS} \
        -DCMAKE_PREFIX_PATH="${PREFIX}" \
        -DCMAKE_CXX_STANDARD=20 \
        -DBUILD_TESTING=ON \
        -DBUILD_WEBSERVICE=ON \
        -DCIFPP_SHARE_DIR="${PREFIX}/share/libcifpp" \
        -Dcifpp_DIR="${PREFIX}/share/cmake/cifpp" \
        -Dmcfp_DIR="${PREFIX}/share/cmake/mcfp" \
        -Dzeep_DIR="${PREFIX}/share/cmake/zeep"
elif [[ "${target_platform}" == "osx-"* ]]; then
    cmake -S . -B build -G Ninja \
        ${CMAKE_ARGS} \
        -DCMAKE_PREFIX_PATH="${PREFIX}" \
        -DCMAKE_CXX_STANDARD=20 \
        -DBUILD_TESTING=ON \
        -DCIFPP_SHARE_DIR="${PREFIX}/share/libcifpp" \
        -Dcifpp_DIR="${PREFIX}/share/cmake/cifpp" \
        -Dmcfp_DIR="${PREFIX}/share/cmake/mcfp"
fi

cmake --build build --config Release --parallel "${CPU_COUNT}"
ctest -V --config Release --test-dir build
cmake --install build
