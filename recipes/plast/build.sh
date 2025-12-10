#!/usr/bin/env bash
set -euo pipefail
mkdir -p "$PREFIX/bin"
mkdir -p build
cd build || exit 1
export CXXFLAGS="${CXXFLAGS} -std=gnu++14"
cmake .. \
  -Wno-dev \
  -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_CXX_STANDARD=14 \
  -DCMAKE_CXX_STANDARD_REQUIRED=ON \
  -DCMAKE_CXX_EXTENSIONS=ON \
  -DCMAKE_CXX_FLAGS="${CXXFLAGS}"
make -j${CPU_COUNT:-2}
make install
install -v -m 0755 bin/Release/plast "$PREFIX"/bin
