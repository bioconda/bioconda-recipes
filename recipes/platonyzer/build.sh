#!/usr/bin/env bash

set -exo pipefail

# Prevent static linking for GNU compilers
sed -i.bak '/if(NOT MSVC AND "${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")/,/endif()/d' CMakeLists.txt

sed -i.bak 's|libmcfp_FOUND|mcfp_FOUND|g' CMakeLists.txt
sed -i.bak 's|TARGET libmcfp)|TARGET mcfp)|g' CMakeLists.txt
sed -i.bak 's|find_package(libmcfp|find_package(mcfp|g' CMakeLists.txt
sed -i.bak 's|libmcfp::libmcfp|mcfp::mcfp|g' CMakeLists.txt

cmake -S . -B build ${CMAKE_ARGS} -G Ninja \
    -DBUILD_SHARED_LIBS=ON \
    -DFFTW2_INCLUDE_DIRS="${PREFIX}/fftw2/include" \
    -DFFTW2_LIBRARY="${PREFIX}/fftw2/lib/libfftw${SHLIB_EXT}" \
    -DRFFTW2_LIBRARY="${PREFIX}/fftw2/lib/librfftw${SHLIB_EXT}" \
    -Wno-dev -Wno-deprecated --no-warn-unused-cli
cmake --build build --parallel ${CPU_COUNT}
cmake --install build --parallel ${CPU_COUNT}
