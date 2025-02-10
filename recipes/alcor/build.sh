#!/bin/bash

# Stop the script if any command returns a non-zero exit status
set -e

# Print each command as it is executed
set -x

# Run cleanup tasks if the script is interrupted
trap 'echo "Interrupted, cleaning up..."' INT

# Set up the build environment
cd "$SRC_DIR/src/"

# Build and install the package
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER=$CXX -DCMAKE_C_COMPILER=$CC .
make

# Copy the executable to the bin directory
mkdir -p "$PREFIX/bin"
cp "$SRC_DIR/src/AlcoR" "$PREFIX/bin/"