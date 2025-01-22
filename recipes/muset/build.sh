#!/bin/bash
set -e
set -x

# Extensive debugging
echo "Build Environment Diagnostics:"
echo "----------------------------"
pwd
ls -la
echo "SRC_DIR: $SRC_DIR"
echo "PREFIX: $PREFIX"

# Check external libraries
echo "External Libraries:"
if [ -d "external" ]; then
    find external -type d
else
    echo "No 'external' directory found!"
    exit 1
fi

# Verify specific library directories
echo "Checking specific library directories:"
LIBS=(fmt kff-cpp-api lz4 spdlog xxHash)
for lib in "${LIBS[@]}"; do
    if [ -d "external/${lib}" ]; then
        echo "Found ${lib} library"
    else
        echo "WARNING: ${lib} library not found"
    fi
done

# Create build directory
mkdir -p ${PREFIX}/bin

mkdir build-conda
cd build-conda

# Verbose CMake configuration
cmake .. \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCONDA_BUILD=ON \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_VERBOSE_MAKEFILE=ON

# Verbose build
make VERBOSE=1 -j${CPU_COUNT}
cd ..

# Copy binaries
cp ./bin/kmat_tools ${PREFIX}/bin
cp ./bin/muset ${PREFIX}/bin
cp ./bin/muset_pa ${PREFIX}/bin

# Final diagnostics
echo "Build Complete. Installed Binaries:"
ls -l ${PREFIX}/bin