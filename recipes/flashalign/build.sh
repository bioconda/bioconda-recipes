#!/bin/bash

set -xe

cmake -S . -B build ${CMAKE_ARGS} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DFLASHALIGN_BUILD_PYTHON=OFF \
    -DFLASHALIGN_VERSION_SUFFIX=OFF
cmake --build build --target flashalign -j "${CPU_COUNT}"
cmake --install build --component CLI
