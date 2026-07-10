#!/bin/bash

set -xe

export CMAKE_ARGS="-DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_INSTALL_LIBDIR=${PREFIX} -DINSTALL_LICENSE_DIR=share/LibCarna"
export CMAKE_ARGS="${CMAKE_ARGS} -DINSTALL_CMAKE_DIR=${PREFIX}/share/cmake/Modules"

# Build
LIBCARNA_NO_INSTALL=1 BUILD=only_release ./linux_build-egl.bash

# Fix FindLibCarna.cmake
sed -i "s|${PREFIX}|\\\$ENV{CONDA_PREFIX}|g" build/make_release/misc/FindLibCarna.cmake

# Install
cd "build/make_release"
make install
