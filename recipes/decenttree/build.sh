#!/usr/bin/env bash
set -euxo pipefail

if [[ "${target_platform}" == osx-* ]]; then
  # Allow for either preserved top-level directory or flattened extraction
  if [[ -f mac/decenttree-1.0.0-MacOSX/bin/decenttree ]]; then
    BIN_PATH="mac/decenttree-1.0.0-MacOSX/bin/decenttree"
  elif [[ -f mac/bin/decenttree ]]; then
    BIN_PATH="mac/bin/decenttree"
  else
    echo "decenttree binary not found in extracted mac archive" >&2
    ls -R mac >&2 || true
    exit 1
  fi
  install -Dm755 "${BIN_PATH}" "${PREFIX}/bin/decenttree"
  mkdir -p "${PREFIX}/share/licenses/decenttree"
  cp source/LICENSE "${PREFIX}/share/licenses/decenttree/LICENSE"
  exit 0
fi

cd source
mkdir -p build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX
make -j${CPU_COUNT}
install -Dm755 decenttree $PREFIX/bin/decenttree
install -Dm644 ../LICENSE "${PREFIX}/share/licenses/decenttree/LICENSE"
