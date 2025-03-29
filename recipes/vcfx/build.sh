#!/bin/bash
set -ex

# Print environment info for debugging
echo "Build environment:"
echo "PREFIX: $PREFIX"
echo "CPU_COUNT: $CPU_COUNT"
echo "CMAKE_ARGS: $CMAKE_ARGS"
echo "CONDA_BUILD_SYSROOT: $CONDA_BUILD_SYSROOT"
echo "ZLIB location:"
find $PREFIX -name "*zlib*" || echo "No zlib found directly"
find $PREFIX -name "libz.*" || echo "No libz found directly"
echo "Library contents:"
ls -la $PREFIX/lib/
echo "Include contents:"
ls -la $PREFIX/include/

# Set environment variables to help find zlib
export CFLAGS="${CFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CMAKE_LIBRARY_PATH=$PREFIX/lib:$CMAKE_LIBRARY_PATH
export CMAKE_INCLUDE_PATH=$PREFIX/include:$CMAKE_INCLUDE_PATH

mkdir -p build
cd build

# Configure with more verbose output
cmake ${CMAKE_ARGS} \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_PREFIX_PATH=${PREFIX} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_VERBOSE_MAKEFILE=ON \
    -DZLIB_ROOT=${PREFIX} \
    -DZLIB_LIBRARY=${PREFIX}/lib/libz${SHLIB_EXT} \
    -DZLIB_INCLUDE_DIR=${PREFIX}/include \
    ..

# Build with specified number of cores
make -j${CPU_COUNT} VERBOSE=1

# Install
make install 