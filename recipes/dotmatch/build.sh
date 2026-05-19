#!/usr/bin/env bash
set -euo pipefail

make \
  CC="${CC}" \
  CFLAGS="${CFLAGS:-} ${CPPFLAGS:-} -std=c11 -Wall -Wextra -Wpedantic -Iinclude" \
  LDFLAGS="${LDFLAGS:-}" \
  dotmatch libdotmatch.a shared

mkdir -p "${PREFIX}/bin" \
         "${PREFIX}/include" \
         "${PREFIX}/lib" \
         "${PREFIX}/share/${PKG_NAME}"

install -m 755 dotmatch "${PREFIX}/bin/dotmatch"
install -m 644 include/qdalign.h "${PREFIX}/include/qdalign.h"
install -m 644 libdotmatch.a "${PREFIX}/lib/libdotmatch.a"
install -m 644 LICENSE "${PREFIX}/share/${PKG_NAME}/LICENSE"

if [[ "$(uname -s)" == "Darwin" ]]; then
  install -m 755 libdotmatch.dylib "${PREFIX}/lib/libdotmatch.dylib"
else
  install -m 755 libdotmatch.so "${PREFIX}/lib/libdotmatch.so"
fi
