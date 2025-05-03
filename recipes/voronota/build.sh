#!/usr/bin/env bash

set -euo pipefail

export CXXFLAGS="${CXXFLAGS} -fopenmp"

mkdir build
cd build

cmake .. \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CXX_COMPILER="${CXX}" \
    -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
    -DCMAKE_EXE_LINKER_FLAGS="${LDFLAGS}" \
    -DEXPANSION_JS=ON \
    -DEXPANSION_LT=ON \
    -DEXPANSION_GL=ON \
    -DENABLE_MPI=ON

make -j"${CPU_COUNT}"
make install
