#!/usr/bin/env bash

set -exo pipefail

# Prevent static linking for GNU compilers
sed -i.bak '/if(NOT MSVC AND "${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")/,/endif()/d' CMakeLists.txt

# # Ensure expected CMake config locations exist and create compatible symlinks
# mkdir -p "${PREFIX}/lib/cmake/mcfp" "${PREFIX}/lib/cmake/libmcfp"
# if [[ -f "${PREFIX}/lib/cmake/mcfp/mcfpConfig.cmake" ]]; then
#   # Provide both libmcfpConfig.cmake and libmcfp-config.cmake in a directory CMake searches
#   ln -sfn "${PREFIX}/lib/cmake/mcfp/mcfpConfig.cmake" "${PREFIX}/lib/cmake/libmcfp/libmcfpConfig.cmake"
#   ln -sfn "${PREFIX}/lib/cmake/mcfp/mcfpConfig.cmake" "${PREFIX}/lib/cmake/libmcfp/libmcfp-config.cmake"
#   # Keep a copy next to the original for backwards compatibility
#   ln -sfn "${PREFIX}/lib/cmake/mcfp/mcfpConfig.cmake" "${PREFIX}/lib/cmake/mcfp/libmcfpConfig.cmake"
#   # Also ensure mcfpTargets.cmake is available where libmcfpConfig expects it
#   if [[ -f "${PREFIX}/lib/cmake/mcfp/mcfpTargets.cmake" ]]; then
#     ln -sfn "${PREFIX}/lib/cmake/mcfp/mcfpTargets.cmake" "${PREFIX}/lib/cmake/libmcfp/mcfpTargets.cmake"
#   fi
# fi

sed -i.bak 's|libmcfp_FOUND|mcfp_FOUND|g' CMakeLists.txt
sed -i.bak 's|TARGET libmcfp)|TARGET mcfp)|g' CMakeLists.txt
sed -i.bak 's|find_package(libmcfp|find_package(mcfp|g' CMakeLists.txt
sed -i.bak 's|libmcfp::libmcfp|mcfp::mcfp|g' CMakeLists.txt

cmake -S . -B build ${CMAKE_ARGS} \
    -DFFTW2_INCLUDE_DIRS="${PREFIX}/fftw2/include" \
    -DFFTW2_LIBRARY="${PREFIX}/fftw2/lib/libfftw${SHLIB_EXT}" \
    -DRFFTW2_LIBRARY="${PREFIX}/fftw2/lib/librfftw${SHLIB_EXT}" \
    -Wno-dev -Wno-deprecated --no-warn-unused-cli
cmake --build build --parallel ${CPU_COUNT}
cmake --install build --parallel ${CPU_COUNT}
