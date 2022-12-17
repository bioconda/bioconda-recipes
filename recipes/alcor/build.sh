#!/bin/bash

# Stop the script if any command returns a non-zero exit status
set -e

# Print each command as it is executed
set -x

# Run cleanup tasks if the script is interrupted
trap 'echo "Interrupted, cleaning up..."' INT

# Check for required dependencies
# if ! which cmake > /dev/null; then
#     echo "CMake not found, installing..."
#     if [ "$(uname)" == "Darwin" ]; then
#         # Install CMake on Mac using Homebrew
#         brew install cmake
#     elif [ "$(uname)" == "Linux" ]; then
#         # Install CMake on Linux using apt-get
#         apt-get update
#         apt-get install -y cmake
#     else
#         echo "Error: Unsupported operating system"
#         exit 1
#     fi
# fi

# Set up the build environment
cd "$SRC_DIR/src/"

# Build and install the package
cmake . -DCMAKE_INSTALL_PREFIX="$PREFIX"
make

# Copy the executable to the bin directory
mkdir -p "$PREFIX/bin"
cp "$SRC_DIR/src/AlcoR" "$PREFIX/bin/"
