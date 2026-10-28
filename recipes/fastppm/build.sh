#!/usr/bin/env bash

# FIX for broken Clang 18 on macOS:
# The llvm-tools package provides broken 'llvm-ar' and 'llvm-ranlib' binaries
# that crash with dyld errors. We delete them so CMake finds the standard 'ar'
# and 'ranlib' provided by cctools instead.
if [[ "$(uname)" == "Darwin" ]]; then
    rm -f $BUILD_PREFIX/bin/llvm-ar
    rm -f $BUILD_PREFIX/bin/llvm-ranlib
fi

mkdir -p build
cd build

# We pass -DFASTPPM_VERSION=$PKG_VERSION so CMake knows the version
# without needing a git history (which conda builds often lack).
cmake -DPYTHON_EXECUTABLE=$PYTHON \
      -DCMAKE_BUILD_TYPE=RELEASE \
      -DFASTPPM_VERSION=$PKG_VERSION \
      ..

make -j${CPU_COUNT}

# Install
mkdir -p $PREFIX/bin
mkdir -p $SP_DIR
cp src/fastppm-cli $PREFIX/bin
cp src/fastppm*.so $SP_DIR
