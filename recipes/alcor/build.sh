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
make CC=$CC CFLAGS="-Wall -O3" -j8

# Copy the executable to the bin directory
mkdir -p "$PREFIX/bin"
cp "$SRC_DIR/src/AlcoR" "$PREFIX/bin/"
