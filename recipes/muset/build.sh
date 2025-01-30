#!/bin/bash
set -e  # Exit on error
set -x  # Print commands for debugging

# Use the version from meta.yaml, which is passed as an environment variable
VERSION=${PKG_VERSION}

# Print the current directory and version for debugging
echo "Current directory: ${PWD}"
echo "Building version: ${VERSION}"
ls -lh

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

# Enhanced binary copying with detailed error checking
copy_binary() {
    local binary=$1
    local src_path="./bin/${binary}"
    local dest_path="${PREFIX}/bin/${binary}"

    # Check if source binary exists
    if [ ! -f "${src_path}" ]; then
        echo "ERROR: Source binary ${src_path} does not exist!"
        exit 1
    fi

    # Check if source binary is executable
    if [ ! -x "${src_path}" ]; then
        echo "ERROR: Source binary ${src_path} is not executable!"
        exit 1
    fi

    # Copy binary
    cp "${src_path}" "${dest_path}"

    # Verify copy
    if [ ! -f "${dest_path}" ]; then
        echo "ERROR: Failed to copy ${binary} to ${dest_path}"
        exit 1
    fi

    # Ensure destination is executable
    chmod +x "${dest_path}"

    echo "Successfully copied and made executable: ${binary}"
}

# Copy binaries with error handling
echo "Copying binaries:"
copy_binary kmat_tools
copy_binary muset
copy_binary muset_pa

# List and verify copied binaries
echo "Verifying copied binaries:"
ls -l ${PREFIX}/bin/
file ${PREFIX}/bin/*

# Verify binary functionality
for binary in kmat_tools muset muset_pa; do
    echo "Checking ${binary}:"
    ${PREFIX}/bin/${binary} --help || echo "Warning: ${binary} --help failed"
done

# Explicit exit with success
exit 0