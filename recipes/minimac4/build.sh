#!/bin/bash
#set -euo pipefail

# Set up dependencies and directories
cmake -P dependencies.cmake deps/
mkdir build && cd build

# Define compilers and make program explicitly
cmake \
    -DCMAKE_PREFIX_PATH=$(pwd)/../deps/ \
    -CMAKE_MAKE_PROGRAM=$(which cmake) \
    -CMAKE_C_COMPILER=${CC} \
    -CMAKE_CXX_COMPILER=${CXX} \
    -DCMAKE_CXX_FLAGS="-I$(pwd)/../deps/include -Wno-dev" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \
    -DCMAKE_EXE_LINKER_FLAGS="-static" \
    -DCPACK_GENERATOR="STGZ" \
    -DCPACK_PACKAGE_CONTACT="csg-devel@umich.edu" \
    ..

# Build and install
make
make install
