#!/usr/bin/env bash

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
