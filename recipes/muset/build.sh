#!/bin/bash
set -e  # Exit on error
set -x  # Print commands for debugging

# Use the version from meta.yaml, which is passed as an environment variable
VERSION=${PKG_VERSION}

# Print the current directory and version for debugging
echo "Current directory: ${PWD}"
echo "Building version: ${VERSION}"
ls -lh

# Initialize git repository
git init

# Add remote origin
git remote add origin https://github.com/CamilaDuitama/muset.git

# Fetch all tags
git fetch --tags

# Force checkout the specific version, overwriting local files
git checkout -f v${VERSION}

# Initialize and update submodules explicitly
git submodule init
git submodule update --recursive

# Verify submodule and external folder contents
echo "Submodule status:"
git submodule status

echo "External folder contents:"
ls -la external/

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
        exit 1
    fi
done

# Verify installed binaries
echo "Installed binaries:"
ls -l ${PREFIX}/bin/