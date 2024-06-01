#!/usr/bin/env bash
set -ex

declare -a CMAKE_PLATFORM_FLAGS
if [[ ${HOST} =~ .*darwin.* ]]; then
    CMAKE_PLATFORM_FLAGS+=(-DCMAKE_OSX_SYSROOT="${CONDA_BUILD_SYSROOT}")
else
    CMAKE_PLATFORM_FLAGS+=(-DCMAKE_TOOLCHAIN_FILE="${RECIPE_DIR}/cross-linux.cmake")
fi

# Create build directory
mkdir -p build
cd build

# Configure the build
cmake -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=${PREFIX} \
      -DCMAKE_MAKE_PROGRAM=make \
      -DCMAKE_CXX_FLAGS="${CMAKE_CXX_FLAGS} -std=c++20 -fopenmp -static-libgcc -static-libstdc++ -isystem ${PREFIX}/include -isystem ${PREFIX}/include/seqan3/submodules/sdsl-lite/include -isystem ${PREFIX}/include/seqan3/submodules/cereal/include -fconcepts -g -Wall -lyaml-cpp -Wno-interference-size -Wno-maybe-uninitialized" \
      ..

# Build and install
make -j${CPU_COUNT}
make install
