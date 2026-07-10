#!/bin/bash

set -xe

mkdir -p $PREFIX/bin

mkdir -p build
cd build

# Since the codebase is C++17, CMAKE_OSX_DEPLOYMENT_TARGET needs to be set to 10.13
# (see https://cibuildwheel.readthedocs.io/en/stable/cpp_standards/#macos-and-deployment-target-versions)
# Further, certain features (related to filesystem/path.h) are only available in macOS 10.15
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_OSX_DEPLOYMENT_TARGET=10.15

make -j ${CPU_COUNT}
cp bin/guidescan $PREFIX/bin
chmod +x $PREFIX/bin/guidescan
