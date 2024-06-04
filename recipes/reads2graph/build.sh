#!/usr/bin/env bash
set -ex

# Add the Conda environment's bin directory to the PATH
export PATH="${PREFIX}/bin:${PATH}"

# Create build directory
mkdir -p build
cd build

# Configure the build
cmake -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=${PREFIX} \
      -DCMAKE_MAKE_PROGRAM=make \
      -DCMAKE_CXX_COMPILER=${CXX} \
      -DCMAKE_TOOLCHAIN_FILE="${RECIPE_DIR}/cross-linux.cmake" \
      -DCMAKE_CXX_FLAGS="${CMAKE_CXX_FLAGS} -std=gnu++20 -fopenmp -static-libgcc -static-libstdc++ -isystem ${PREFIX}/include -isystem ${PREFIX}/include/seqan3/submodules/sdsl-lite/include -isystem ${PREFIX}/include/seqan3/submodules/cereal/include -fconcepts -g -Wall -lyaml-cpp -Wno-interference-size -Wno-maybe-uninitialized" \
      ..

make
cp ../bin/reads2graph $PREFIX/bin/reads2graph