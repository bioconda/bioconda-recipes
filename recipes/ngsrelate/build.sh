#!/usr/bin/env bash
set -euo pipefail

export DYLD_FALLBACK_LIBRARY_PATH="${BUILD_PREFIX}/lib:${PREFIX}/lib:${DYLD_FALLBACK_LIBRARY_PATH:-}"

make clean
make -j"${CPU_COUNT:-1}" \
  CC="${CC}" \
  CXX="${CXX}" \
  HTSSRC=systemwide \
  PACKAGE_VERSION="${PKG_VERSION}"

install -d "${PREFIX}/bin"
install -m 755 ngsRelate "${PREFIX}/bin/ngsRelate"
