#!/bin/bash
set -ex

# 1. Build the Rust API
# This generates the core Rust objects needed for the C++ bindings
cd external/ggcat/crates/capi/ggcat-cpp-api
head -n 15 Makefile > Makefile.tmp
mv Makefile.tmp Makefile
make

cd "${SRC_DIR}"
LIB_PATH=$(find . -name "libggcat_cpp_bindings.a" | head -n 1)

if [ -z "$LIB_PATH" ]; then
    echo "ERROR: libggcat_cpp_bindings.a not found after cargo build!"
    exit 1
fi

echo "Found bindings at: ${LIB_PATH}"

# Manually satisfy the GGCAT Makefile's requirement by placing it in its local lib folder
cp "$LIB_PATH" "external/ggcat/crates/capi/ggcat-cpp-api/lib/"

# 3. Path Synchronization
# We need to find the libraries and move them to the 'target/release' 
# folder where Fulgor's main build is hardcoded to look for them.

mkdir build
cd build

cmake ..

# Parallel build using available CPU cores
make -j${CPU_COUNT}

# 5. Installation
# Move the binary to the Conda environment's bin directory
mkdir -p "${PREFIX}/bin"
cp fulgor "${PREFIX}/bin/"
