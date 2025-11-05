#!/bin/bash
set -e  # Exit on error
set -x  # Print commands for debugging

# Use the version from meta.yaml, which is passed as an environment variable
VERSION=${PKG_VERSION}

# Print the current directory and version for debugging
echo "Current directory: ${PWD}"
echo "Building version: ${VERSION}"
ls -lh

# Explicitly initialize and update git submodules
echo "Initializing git submodules..."
git submodule update --init --recursive
echo "Submodules initialized. Listing external/lz4:"
ls -la external/lz4/ | head -20

# Create the output directory
mkdir -p ${PREFIX}/bin

# Configure the build with CMake, with verbose output
# Disable BUILD_TESTING to avoid downloading GoogleTest
# NOTE: Do NOT use -DCONDA_BUILD=ON since we're building LZ4 from source
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
