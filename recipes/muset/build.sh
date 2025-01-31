#!/bin/bash
set -e  # Exit on error
set -x  # Print commands for debugging

# Use the version from meta.yaml, which is passed as an environment variable
VERSION=${PKG_VERSION}

# Print the current directory and version for debugging
echo "Current directory: ${PWD}"
echo "Building version: ${VERSION}"
ls -lh

# Initialize git repository if it doesn't exist
if [ ! -d ".git" ]; then
    echo "Initializing git repository"
    git init
    git remote add origin https://github.com/CamilaDuitama/muset.git
fi

# Fetch tags (this might not work if not a full clone)
git fetch --tags || echo "Warning: Could not fetch tags"

# Try to checkout the specific version
if ! git checkout v${VERSION}; then
    echo "Direct git checkout failed. Continuing with build."
fi

# Initialize and update submodules
# This might require --init if submodules are not already present
git submodule init || echo "Submodule init may have failed"
git submodule update --recursive || echo "Submodule update may have failed"

# Verify submodule and external folder contents
echo "Submodule status:"
git submodule status || echo "Could not get submodule status"

echo "External folder contents:"
ls -la external/ || echo "Could not list external folder"

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
BINARIES=("kmat_tools" "muset" "muset_pa")
for binary in "${BINARIES[@]}"; do
    if [ -x "./bin/${binary}" ]; then
        cp "./bin/${binary}" ${PREFIX}/bin/
        echo "Copied ${binary}"
    else
        echo "Warning: Binary ${binary} not found or not executable"
        # List contents of bin directory to debug
        ls -l ./bin/
    fi
done

# Verify copied binaries
echo "Verifying copied binaries:"
ls -l ${PREFIX}/bin/