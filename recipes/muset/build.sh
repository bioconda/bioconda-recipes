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

# Comprehensive executable search
echo "Finding ALL executables:"
find . -type f -executable

# Detailed recursive search with file information
echo "Detailed executable search:"
find . -type f -executable -exec file {} \;

# Check build-conda directory
echo "Executables in build-conda:"
find build-conda -type f -executable

# Check bin directory
echo "Contents of bin directory:"
ls -la bin/

# Copy executables
BINARIES=(kmat_tools muset-kmtricks muset muset_pa)
for binary in "${BINARIES[@]}"; do
    # Comprehensive search strategies
    found_binary=$(find . -type f -executable -name "${binary}" | head -n 1)
    
    if [ -n "$found_binary" ]; then
        echo "Found binary: $found_binary"
        cp "$found_binary" ${PREFIX}/bin/
    else
        echo "Warning: Binary ${binary} not found in any location!"
    fi
done

# Verify installed binaries
echo "Installed binaries:"
ls -l ${PREFIX}/bin/