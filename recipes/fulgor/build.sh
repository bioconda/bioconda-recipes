#!/bin/bash

mkdir build
cd build

# Run CMake
cmake .. ${CMAKE_ARGS} \
    -DCMAKE_BUILD_TYPE=Release \
    -DFULGOR_USE_SANITIZERS=OFF

# Compile using all available CPU cores
make -j${CPU_COUNT}

# INSTEAD OF 'make install', manually copy the binary
mkdir -p "${PREFIX}/bin"
cp fulgor "${PREFIX}/bin/"
