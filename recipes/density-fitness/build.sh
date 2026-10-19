#!/usr/bin/env bash

set -exo pipefail

if [[ "${target_platform}" == "osx-"* ]]; then
    export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

# Workaround for CMakeLists.txt to find FastFloat package
sed -i.bak '/^cmake_minimum_required(VERSION/a\
find_package(FastFloat REQUIRED CONFIG)
' CMakeLists.txt

cmake -S . -B build ${CMAKE_ARGS} -G Ninja \
    -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
    -DBUILD_SHARED_LIBS=ON \
    -DFastFloat_DIR="${PREFIX}/share/cmake/FastFloat" \
    -DFFTW2_INCLUDE_DIRS="${PREFIX}/fftw2/include" \
    -DFFTW2_LIBRARY="${PREFIX}/fftw2/lib/libfftw${SHLIB_EXT}" \
    -DRFFTW2_LIBRARY="${PREFIX}/fftw2/lib/librfftw${SHLIB_EXT}" \
    -Wno-dev -Wno-deprecated --no-warn-unused-cli
cmake --build build --parallel ${CPU_COUNT}
cmake --install build --parallel ${CPU_COUNT}
