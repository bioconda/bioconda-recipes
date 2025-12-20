#!/usr/bin/env bash

set -exo pipefail

cmake -S . -B build ${CMAKE_ARGS} -G Ninja \
    -DBUILD_SHARED_LIBS=ON \
    -DFFTW2_INCLUDE_DIRS="${PREFIX}/fftw2/include" \
    -DFFTW2_LIBRARY="${PREFIX}/fftw2/lib/libfftw${SHLIB_EXT}" \
    -DRFFTW2_LIBRARY="${PREFIX}/fftw2/lib/librfftw${SHLIB_EXT}" \
    -Wno-dev -Wno-deprecated --no-warn-unused-cli
cmake --build build --parallel ${CPU_COUNT}
cmake --install build --parallel ${CPU_COUNT}
