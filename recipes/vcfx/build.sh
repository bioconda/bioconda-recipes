#!/bin/bash
set -ex

# Print environment info for debugging
echo "Build environment:"
echo "PREFIX: $PREFIX"
echo "CPU_COUNT: $CPU_COUNT"
echo "CMAKE_ARGS: $CMAKE_ARGS"
echo "CONDA_BUILD_SYSROOT: $CONDA_BUILD_SYSROOT"
echo "ZLIB location:"
find $PREFIX -name "*zlib*"
ls -la

mkdir -p build
cd build

# Configure with more verbose output
cmake ${CMAKE_ARGS} \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_PREFIX_PATH=${PREFIX} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_VERBOSE_MAKEFILE=ON \
    -DZLIB_ROOT=${PREFIX} \
    ..

# Build with specified number of cores
make -j${CPU_COUNT} VERBOSE=1

# Install
make install 