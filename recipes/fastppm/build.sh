#!/usr/bin/env bash

mkdir -p build
cd build

# We pass -DFASTPPM_VERSION=$PKG_VERSION so CMake knows the version
# without needing a git history (which conda builds often lack).
# Fix for macOS: explicitly pass the AR and RANLIB tools set by Conda
# so CMake doesn't find broken ones in the package cache.
cmake -DPYTHON_EXECUTABLE=$PYTHON \
      -DCMAKE_BUILD_TYPE=RELEASE \
      -DFASTPPM_VERSION=$PKG_VERSION \
      -DCMAKE_AR="${AR}" \
      -DCMAKE_RANLIB="${RANLIB}" \
      ..

make -j${CPU_COUNT}

# Install
mkdir -p $PREFIX/bin
mkdir -p $SP_DIR
cp src/fastppm-cli $PREFIX/bin
cp src/fastppm*.so $SP_DIR
