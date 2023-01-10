#!/bin/bash
export C_INCLUDE_PATH=$C_INCLUDE_PATH:${PREFIX}/include
export LIBRARY_PATH=$LIBRARY_PATH:${PREFIX}/lib

# Stop the script if any command returns a non-zero exit status
set -e

# Print each command as it is executed
set -x

# Run cleanup tasks if the script is interrupted
trap 'echo "Interrupted, cleaning up..."' INT

# Set up the build environment
cd "$SRC_DIR/src/"

# Build and install the package
make CC=$CC CFLAGS="$CFLAGS -fcommon"


# Copy the executable to the bin directory
mkdir -f "MakefileConda" -p "$PREFIX/bin"
cp "$SRC_DIR/src/AlcoR" "$PREFIX/bin/"
