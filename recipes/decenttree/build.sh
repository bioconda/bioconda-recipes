#!/usr/bin/env bash
set -euxo pipefail

if [[ "${target_platform}" == osx-* ]]; then
  install -Dm755 mac/decenttree-1.0.0-MacOSX/bin/decenttree "${PREFIX}/bin/decenttree"
  install -Dm644 source/LICENSE "${PREFIX}/share/licenses/decenttree/LICENSE"
  exit 0
fi

cd source
mkdir -p build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX
make -j${CPU_COUNT}
install -Dm755 decenttree $PREFIX/bin/decenttree
install -Dm644 ../LICENSE "${PREFIX}/share/licenses/decenttree/LICENSE"
