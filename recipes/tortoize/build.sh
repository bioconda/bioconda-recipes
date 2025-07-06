#!/bin/bash

set -exo pipefail

# - sed -i.bak '/if (NOT TARGET dssp)/i find_package(dssp QUIET)' CMakeLists.txt
sed -i.bak 's|if (NOT TARGET dssp)|find_package(dssp QUIET)\nif(NOT TARGET dssp::dssp AND NOT TARGET dssp)|g' CMakeLists.txt
# - sed -i 's/find_or_fetch_package(cifpp VERSION 7/find_package(cifpp QUIET)\nif(NOT cifpp_FOUND)\n  find_or_fetch_package(cifpp VERSION 7/g' CMakeLists.txt
# - sed -i 's/GIT_TAG v7.0.9 VARIABLES "CIFPP_SHARE_DIR")/GIT_TAG v7.0.9 VARIABLES "CIFPP_SHARE_DIR")\nendif()/g' CMakeLists.txt

cmake -S . -B build \
    ${CMAKE_ARGS} \
    -DCMAKE_PREFIX_PATH="${PREFIX}" \
    -DCMAKE_CXX_STANDARD=20 \
    -DBUILD_TESTING=OFF \
    -DBUILD_WEBSERVICE=ON \
    -DCIFPP_DATA_DIR='' \
    -DCIFPP_SHARE_DIR="${PREFIX}/share/libcifpp" \
    -Dcifpp_DIR="${PREFIX}/share/cmake/libcifpp" \
    -Dmcfp_DIR="${PREFIX}/share/cmake/libmcfp" \
    -Dzeep_DIR="${PREFIX}/share/cmake/zeep"

cmake --build build --config Release --parallel "${CPU_COUNT}"
cmake --install build
