#!/bin/bash
set -e
set -x

# Diagnostic information about external libraries
echo "External libraries diagnostic:"
echo "Current directory: $(pwd)"
echo "Listing directories:"
find . -type d | grep -E "external|fmt"

# Verify external directory exists
if [ ! -d "external" ]; then
    echo "ERROR: No 'external' directory found!"
    exit 1
fi

# Check fmt directory specifically
if [ ! -d "external/fmt" ]; then
    echo "ERROR: fmt directory not found in external!"
    echo "Contents of external directory:"
    ls -la external
    exit 1
fi

mkdir -p ${PREFIX}/bin

mkdir build-conda
cd build-conda

# More robust CMake configuration
cmake .. \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCONDA_BUILD=ON \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_VERBOSE_MAKEFILE=ON

# Build with verbose output and all cores
make VERBOSE=1 -j${CPU_COUNT}
cd ..

# Copy binaries
cp ./bin/kmat_tools ${PREFIX}/bin
cp ./bin/muset ${PREFIX}/bin
cp ./bin/muset_pa ${PREFIX}/bin