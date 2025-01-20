#!/bin/bash
set -e
set -x

# Extensive debugging for external libraries
echo "Current working directory:"
pwd

echo "Listing current directory contents:"
ls -la

echo "Checking external directory:"
if [ -d "external" ]; then
    echo "External directory exists"
    find external -type d
else
    echo "ERROR: external directory does not exist!"
fi

echo "Checking specific library directories:"
for lib in fmt kff-cpp-api lz4 spdlog xxHash; do
    if [ -d "external/${lib}" ]; then
        echo "Contents of external/${lib}:"
        ls -la "external/${lib}"
    else
        echo "Warning: external/${lib} directory not found"
    fi
done

# Create build directory
mkdir -p ${PREFIX}/bin
mkdir build-conda
cd build-conda

# CMake with verbose output
cmake .. \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCONDA_BUILD=ON \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_VERBOSE_MAKEFILE=ON

# Build with maximum verbosity
make VERBOSE=1 -j8

# Install
cd ..
cp ./bin/kmat_tools ${PREFIX}/bin
cp ./bin/muset ${PREFIX}/bin
cp ./bin/muset_pa ${PREFIX}/bin
