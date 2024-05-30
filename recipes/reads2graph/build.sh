#!/usr/bin/env bash
set -ex

# Ensure that the Make program is available
if [ -z "$(command -v make)" ]; then
    echo "Error: 'make' command not found."
    exit 1
fi

# Create build directory
mkdir -p build
cd build

export CMAKE_MAKE_PROGRAM=$(command -v make)

# Configure the build
cmake -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=${PREFIX} \
      -DCMAKE_CXX_COMPILER=${CXX} \
      -DCMAKE_CXX_FLAGS="${CMAKE_CXX_FLAGS} -std=c++20 -fopenmp -static-libgcc -static-libstdc++ -isystem ${PREFIX}/include -isystem ${PREFIX}/include/seqan3/submodules/sdsl-lite/include -isystem ${PREFIX}/include/seqan3/submodules/cereal/include -fconcepts -g -Wall -lyaml-cpp -Wno-interference-size -Wno-maybe-uninitialized" \
      ..

# Build and install
make -j${CPU_COUNT}
make install
