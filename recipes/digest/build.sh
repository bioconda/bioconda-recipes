#!/bin/bash

set -xe

BUILD_DIR="${SRC_DIR}/build"

# Detect OS and architecture
OS=$(uname -s)
ARCH=$(uname -m)

# Set LDFLAGS for macOS to avoid GNU-style linker flags
if [ "$OS" = "Darwin" ]; then
    # Save original LDFLAGS
    OLD_LDFLAGS="$LDFLAGS"
    # Remove GNU-style linker flags for meson
    export LDFLAGS=$(echo $LDFLAGS | sed 's/-Wl,--version//g')
fi

# Run meson
meson setup --prefix=${PREFIX} --buildtype=release "${BUILD_DIR}"
meson install -C "${BUILD_DIR}"

# Restore original LDFLAGS if on macOS
if [ "$OS" = "Darwin" ]; then
    export LDFLAGS="$OLD_LDFLAGS"
fi

# Base compilation flags
COMPILE_FLAGS="-O3 -Wall -shared -std=c++17 -fPIC $(python3 -m pybind11 --includes) \
    -I${SRC_DIR}/pybind \
    -I${SRC_DIR}/include \
    -I${PREFIX}/include \
    -L${PREFIX}/lib"

# Add platform-specific flags
if [ "$OS" = "Darwin" ]; then
    # macOS specific flags
    COMPILE_FLAGS="$COMPILE_FLAGS -undefined dynamic_lookup"
    if [ "$ARCH" = "arm64" ]; then
        # Additional arm64 specific flags for conda-build
        COMPILE_FLAGS="$COMPILE_FLAGS -mmacosx-version-min=11.0"
    else
        # x86_64 specific flags
        COMPILE_FLAGS="$COMPILE_FLAGS -mmacosx-version-min=10.15"
    fi
fi

# Create lib directory if it doesn't exist
mkdir -p ${PREFIX}/lib

# Build the extension directly in the lib directory
$CXX $COMPILE_FLAGS pybind/bindings.cpp -o ${PREFIX}/lib/digest$(python3-config --extension-suffix)

# Create the Python package directory if it doesn't exist
mkdir -p ${SP_DIR}

# Copy the extension to the Python site-packages
cp ${PREFIX}/lib/digest$(python3-config --extension-suffix) ${SP_DIR}/
touch ${SP_DIR}/__init__.py
