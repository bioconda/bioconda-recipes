#!/usr/bin/env bash
set -euo pipefail
mkdir -p build
cd build || exit 1
cmake .. -Wno-dev -DCMAKE_POLICY_VERSION_MINIMUM=3.5 -DCMAKE_INSTALL_PREFIX=${PREFIX}
#-DCMAKE_INSTALL_INCLUDEDIR=${PREFIX}/include -DCMAKE_INSTALL_LIBDIR=${PREFIX}/lib
make -j${CPU_COUNT}
mkdir -p "$PREFIX/bin" "${PREFIX}/include" "${PREFIX}/lib"
make install
cp bin/plast "$PREFIX"/bin/plast
chmod +x "$PREFIX"/bin/plast
