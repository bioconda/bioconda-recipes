#!/bin/bash

# Stop the script if any command returns a non-zero exit status
set -e

# Print each command as it is executed
set -x

echo "======== Starting build script ========"
echo "Build environment:"
echo "PREFIX: $PREFIX"
echo "CPU_COUNT: $CPU_COUNT"
echo "CMAKE_ARGS: $CMAKE_ARGS"
echo "CONDA_BUILD_SYSROOT: $CONDA_BUILD_SYSROOT"
echo "Current directory: $(pwd)"
echo "Directory contents:"
ls -la

echo "======== Checking for dependencies ========"
echo "ZLIB location:"
find $PREFIX -name "*zlib*" || echo "No zlib found directly"
find $PREFIX -name "libz.*" || echo "No libz found directly"
echo "BZIP2 location:"
find $PREFIX -name "*bzip2*" || echo "No bzip2 found directly"
find $PREFIX -name "libbz2.*" || echo "No libbz2 found directly"
echo "Library contents:"
ls -la $PREFIX/lib/ || echo "Could not list lib directory"
echo "Include contents:"
ls -la $PREFIX/include/ || echo "Could not list include directory"

echo "======== Setting environment variables ========"
# Set environment variables to help find zlib and bzip2
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
mkdir -p build
cd build
echo "Now in directory: $(pwd)"

echo "======== Running CMake ========"
# Try to find dependencies manually before CMake
echo "Searching for libraries:"
find / -name "libz.so*" -o -name "libz.dylib*" -o -name "libbz2.so*" -o -name "libbz2.dylib*" 2>/dev/null | head -10 || echo "No libraries found in search"

# Configure with more verbose output
cmake ${CMAKE_ARGS} \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_PREFIX_PATH=${PREFIX} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_VERBOSE_MAKEFILE=ON \
    -DZLIB_ROOT=${PREFIX} \
    -DZLIB_LIBRARY=${PREFIX}/lib/libz${SHLIB_EXT} \
    -DZLIB_INCLUDE_DIR=${PREFIX}/include \
    -DBZIP2_ROOT_DIR=${PREFIX} \
    -DBZIP2_INCLUDE_DIR=${PREFIX}/include \
    -DBZIP2_LIBRARIES=${PREFIX}/lib/libbz2${SHLIB_EXT} \
    .. || { echo "======== CMake configuration failed ========"; exit 1; }

echo "======== CMake completed successfully ========"
echo "CMake files:"
find . -name "CMakeCache.txt" -o -name "CMakeFiles" | head -10
echo "CMakeCache.txt contents:"
cat CMakeCache.txt | grep -i "zlib\|bzip2" || echo "No zlib or bzip2 info in CMakeCache.txt"

echo "======== Running Make ========"
# Build with specified number of cores
make -j${CPU_COUNT} VERBOSE=1 || { echo "======== Make failed ========"; exit 1; }

echo "======== Make completed successfully ========"

echo "======== Running Make Install ========"
# Install
make install || { echo "======== Make install failed ========"; exit 1; }

echo "======== Build completed successfully ========" 
