#!/bin/bash
set -e
set -x

# Create a build directory
mkdir -p build-conda
cd build-conda

# Configure the build
cmake .. \
    -DCONDA_BUILD=ON \
    -Dexternal_dir=${SRC_DIR}/external \
    -Dexternal_bindir=${PWD}/external \
    -Dcmake_path=${SRC_DIR}/cmake \
    -DCMAKE_INSTALL_PREFIX=${PREFIX}

# Build the project
make -j${CPU_COUNT}

# Manually copy the binaries to ${PREFIX}/bin
mkdir -p ${PREFIX}/bin
cp ./bin/kmat_tools ${PREFIX}/bin
cp ./bin/muset ${PREFIX}/bin
cp ./bin/muset_pa ${PREFIX}/bin