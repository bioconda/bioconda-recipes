#!/usr/bin/env bash
set -euxo pipefail

if [[ "$target_platform" == linux-* ]]; then
  mkdir -p build
  cd build
  cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX
  make -j${CPU_COUNT}
  install -Dm755 decenttree $PREFIX/bin/decenttree

elif [[ "$target_platform" == osx-* ]]; then
  # prebuilt binary lives under decenttree-<ver>-MacOSX/bin/
  cd decenttree-*-MacOSX
  install -Dm755 bin/decenttree $PREFIX/bin/decenttree
fi
