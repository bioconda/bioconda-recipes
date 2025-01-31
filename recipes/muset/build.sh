#!/bin/bash
set -e  # Exit on error
set -x  # Print commands for debugging

# Use the version from meta.yaml, which is passed as an environment variable
VERSION=${PKG_VERSION}

# Print the current directory and version for debugging
echo "Current directory: ${PWD}"
echo "Building version: ${VERSION}"
ls -lh

# Ensure git is initialized
git init

# Add remote origin
git remote add origin https://github.com/CamilaDuitama/muset.git

# Fetch all tags
git fetch --tags

# Force checkout the specific version, overwriting local files
git checkout -f v${VERSION}

# Forcefully initialize and update submodules
git submodule init
git submodule update --force --recursive --init

# Debug: Check submodule status and contents
echo "Submodule status:"
git submodule status

echo "External folder contents:"
ls -la external/

# Verify each external library is present
LIBS=(
    "fmt"
    "TurboPFor-Integer-Compression"
    "bcli"
    "cfrcat"
    "gatb-core-stripped"
    "kff-cpp-api"
    "lz4"
    "spdlog"
    "xxHash"
)

for lib in "${LIBS[@]}"; do
    if [ ! -d "external/${lib}" ] || [ -z "$(ls -A external/${lib})" ]; then
        echo "WARNING: ${lib} is missing or empty!"
        # Attempt to clone or download
        case $lib in
            "fmt")
                git clone https://github.com/fmtlib/fmt.git external/fmt
                ;;
            # Add more library-specific fallback cloning if needed
        esac
    fi
done

# Create the output directory
mkdir -p ${PREFIX}/bin

# Create a build directory
mkdir -p build-conda
cd build-conda

# Configure the build with CMake, with verbose output
cmake .. \
    -DCONDA_BUILD=ON \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_VERBOSE_MAKEFILE=ON

# Build the software with verbose output
make -j${CPU_COUNT} VERBOSE=1

# Go back to source directory
cd ..

echo "Current directory: ${PWD}"
ls -lh

# Copy binaries with error checking
for binary in kmat_tools muset muset_pa; do
    if [ -x "./bin/${binary}" ]; then
        cp "./bin/${binary}" ${PREFIX}/bin/
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