#!/bin/bash
set -ex

echo "Build GGCAT"

(cd external/ggcat/crates/capi/ggcat-cpp-api && make)

LIB_PATH=$(find . -name "libggcat_cpp_bindings.a" | head -n 1)
if [ -z "$LIB_PATH" ]; then
    echo "ERROR: libggcat_cpp_bindings.a not found after cargo build!"
    exit 1
fi
echo "Found bindings at: ${LIB_PATH}"
cp "$LIB_PATH" "external/ggcat/crates/capi/ggcat-cpp-api/lib/"

echo "Build Fulgor"

mkdir build
cd build
cmake ..
make -j${CPU_COUNT}

# Installation
# Move the binary to the Conda environment's bin directory
mkdir -p "${PREFIX}/bin"
cp fulgor "${PREFIX}/bin/"
