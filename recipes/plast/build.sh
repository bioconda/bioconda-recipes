#!/usr/bin/env bash
set -euo pipefail
mkdir -p "$PREFIX/bin"
mkdir -p build
cd build || exit 1
cmake .. -Wno-dev -DCMAKE_POLICY_VERSION_MINIMUM=3.5 -DCMAKE_INSTALL_PREFIX=${PREFIX}
make -j${CPU_COUNT}
make install
install -v -m 0755 bin/plast "$PREFIX"/bin
