#!/bin/bash
set -x  # Print commands as they are executed
# Do not use "set -e" to avoid early termination, instead check each step manually

echo "======== Starting build script ========"
echo "Build environment:"
echo "PREFIX: $PREFIX"
echo "CPU_COUNT: $CPU_COUNT"
echo "CMAKE_ARGS: $CMAKE_ARGS"
echo "CONDA_BUILD_SYSROOT: $CONDA_BUILD_SYSROOT"
echo "Current directory: $(pwd)"
echo "Directory contents:"
ls -la

echo "======== Checking for zlib ========"
echo "ZLIB location:"
find $PREFIX -name "*zlib*" || echo "No zlib found directly"
find $PREFIX -name "libz.*" || echo "No libz found directly"
echo "Library contents:"
ls -la $PREFIX/lib/ || echo "Could not list lib directory"
echo "Include contents:"
ls -la $PREFIX/include/ || echo "Could not list include directory"

echo "======== Setting environment variables ========"
# Set environment variables to help find zlib
export CFLAGS="${CFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CMAKE_LIBRARY_PATH=$PREFIX/lib:$CMAKE_LIBRARY_PATH
export CMAKE_INCLUDE_PATH=$PREFIX/include:$CMAKE_INCLUDE_PATH

echo "Environment variables set:"
echo "CFLAGS: $CFLAGS"
echo "CXXFLAGS: $CXXFLAGS"
echo "LDFLAGS: $LDFLAGS"
echo "CMAKE_LIBRARY_PATH: $CMAKE_LIBRARY_PATH"
echo "CMAKE_INCLUDE_PATH: $CMAKE_INCLUDE_PATH"

echo "======== Creating build directory ========"
mkdir -p build || { echo "Failed to create build directory"; exit 1; }
cd build || { echo "Failed to change to build directory"; exit 1; }
echo "Now in directory: $(pwd)"

echo "======== Running CMake ========"
# Try to find zlib manually before CMake
echo "Searching for libz:"
find / -name "libz.so*" -o -name "libz.dylib*" 2>/dev/null | head -10 || echo "No libz found in search"

# Configure with more verbose output
cmake ${CMAKE_ARGS} \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_PREFIX_PATH=${PREFIX} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_VERBOSE_MAKEFILE=ON \
    -DZLIB_ROOT=${PREFIX} \
    -DZLIB_LIBRARY=${PREFIX}/lib/libz${SHLIB_EXT} \
    -DZLIB_INCLUDE_DIR=${PREFIX}/include \
    .. || { echo "======== CMake configuration failed ========"; exit 1; }

echo "======== CMake completed successfully ========"
echo "CMake files:"
find . -name "CMakeCache.txt" -o -name "CMakeFiles" | head -10
echo "CMakeCache.txt contents:"
cat CMakeCache.txt | grep -i zlib || echo "No zlib info in CMakeCache.txt"

echo "======== Running Make ========"
# Build with specified number of cores
make -j${CPU_COUNT} VERBOSE=1 || { echo "======== Make failed ========"; exit 1; }

echo "======== Make completed successfully ========"

echo "======== Running Make Install ========"
# Install
make install || { echo "======== Make install failed ========"; exit 1; }

echo "======== Build completed successfully ========" 