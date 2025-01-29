#!/bin/bash
set -e  # Exit on error
set -x  # Print commands for debugging

# Use the version from meta.yaml, which is passed as an environment variable
VERSION=${PKG_VERSION}

# Print the current directory and version for debugging
echo "Current directory: ${PWD}"
echo "Building version: ${VERSION}"
ls -lh

# Use git fetch to get the tag
git fetch origin tags/v${VERSION}

# Checkout the tag using -f to force overwrite
git checkout -f v${VERSION}

# Initialize and update submodules explicitly
git submodule init
git submodule update --recursive

# Print submodule status
git submodule status

# Create the output directory
mkdir -p ${PREFIX}/bin

# Create a build directory
mkdir -p build-conda
cd build-conda

# Configure the build with CMake
cmake .. -DCONDA_BUILD=ON

# Build the software
make -j${CPU_COUNT}

# Go back to source directory
cd ..

echo "Current directory: ${PWD}"
ls -lh

# Check if binaries exist before copying
BINARIES=(kmat_tools muset-kmtricks muset muset_pa)
for binary in "${BINARIES[@]}"; do
    if [ -f "./bin/${binary}" ]; then
        cp "./bin/${binary}" ${PREFIX}/bin/
    else
        echo "Warning: Binary ${binary} not found!"
        # Optionally, you could exit with an error here
        # exit 1
    fi
done