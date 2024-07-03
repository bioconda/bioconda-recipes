#!/usr/bin/env bash

set -x

mkdir build
cd build

cmake .. -DCMAKE_C_COMPILER="${CC}" -DCMAKE_C_FLAGS="${CFLAGS}" -DCMAKE_CXX_COMPILER="${CXX}" -DCMAKE_CXX_FLAGS="${CXXLAGS}" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX:PATH="${PREFIX}"
make -j ${CPU_COUNT}

