#!/bin/bash

BUILD_DIR="${SRC_DIR}/build"

meson setup --prefix=${PREFIX} --buildtype=release "${BUILD_DIR}"
meson install -C "${BUILD_DIR}"

# Detect OS and architecture
OS=$(uname -s)
ARCH=$(uname -m)

# Base compilation flags
COMPILE_FLAGS="-O3 -Wall -shared -std=c++17 -fPIC $(python3 -m pybind11 --includes) \
    -I${SRC_DIR}/pybind \
    -I${SRC_DIR}/include \
    -I${PREFIX}/include \
    -L${PREFIX}/lib"

# Add dynamic_lookup flag only for macOS
if [ "$OS" = "Darwin" ]; then
    COMPILE_FLAGS="$COMPILE_FLAGS -undefined dynamic_lookup"
fi

$CXX $COMPILE_FLAGS pybind/bindings.cpp -o ${PREFIX}/digest$(python3-config --extension-suffix)

cp ${PREFIX}/digest$(python3-config --extension-suffix) ${SP_DIR}
touch ${SP_DIR}/__init__.py