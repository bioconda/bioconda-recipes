#!/bin/bash
set -e  # Exit on error
set -x  # Print commands for debugging

# Use the version from meta.yaml, which is passed as an environment variable
VERSION=${PKG_VERSION}

# Print the current directory and version for debugging
echo "Current directory: ${PWD}"
echo "Building version: ${VERSION}"
ls -lh

# Check if this is a git repo and if submodules exist
echo "=== Checking git repository status ==="
git status || echo "Not a git repository or git not available"
echo "=== Checking .gitmodules ==="
cat .gitmodules || echo "No .gitmodules file"

# Check if submodules directory exists
echo "=== Checking external directory before submodule init ==="
ls -la external/ | head -20
ls -la external/lz4/ | head -10 || echo "external/lz4 does not exist or is empty"

# Try to initialize submodules if they're not already there
if [ ! -f "external/lz4/lib/lz4.h" ]; then
    echo "=== LZ4 submodule not populated, attempting to initialize ==="
    git submodule update --init --recursive || echo "git submodule command failed"
    echo "=== After submodule init ==="
    ls -la external/lz4/ | head -20
fi

# Verify LZ4 source is present
if [ ! -f "external/lz4/lib/lz4.h" ]; then
    echo "ERROR: LZ4 source not found after submodule initialization!"
    echo "Contents of external/lz4:"
    ls -laR external/lz4/ || echo "Directory does not exist"
    exit 1
fi

echo "=== LZ4 source verified, proceeding with build ==="

# Create the output directory
mkdir -p ${PREFIX}/bin

# Configure the build with CMake, with verbose output
# Disable BUILD_TESTING to avoid downloading GoogleTest
cmake -S . -B build-conda \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_VERBOSE_MAKEFILE=ON \
    -DBUILD_TESTING=OFF

# Build the software with verbose output
cmake --build build-conda -j${CPU_COUNT} --verbose

echo "Current directory: ${PWD}"
ls -lh

# Copy binaries with error checking
for binary in kmat_tools muset muset_pa; do
    if [ -x "./bin/${binary}" ]; then
        install -v -m 0755 "./bin/${binary}" ${PREFIX}/bin/
        echo "Copied ${binary}"
    else
        echo "ERROR: ${binary} not found or not executable"
        ls -l ./bin/
        exit 1
    fi
done

# Verify copied binaries
echo "Verifying copied binaries:"
ls -l ${PREFIX}/bin/
