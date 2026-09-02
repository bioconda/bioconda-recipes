#!/usr/bin/env bash
set -euo pipefail

# Bioconda sets -march=core2 on osx-64, which conflicts with DotMatch's Makefile
# unconditionally appending -mavx2 for x86_64 and can abort clang during qdalign.c.
if [[ "$(uname -s)" == "Darwin" && "$(uname -m)" == "x86_64" ]]; then
  sed -i.bak '/CFLAGS += -mavx2/d; /CXXFLAGS += -mavx2/d' Makefile
fi

make \
  DOTMATCH_VERSION="${PKG_VERSION}" \
  CC="${CC}" \
  CFLAGS="${CFLAGS:-} ${CPPFLAGS:-} -std=c11 -Wall -Wextra -Wpedantic -Iinclude" \
  LDFLAGS="${LDFLAGS:-}" \
  libdotmatch.a shared

mkdir -p "${PREFIX}/bin" \
         "${PREFIX}/include" \
         "${PREFIX}/lib" \
         "${PREFIX}/share/${PKG_NAME}"

${PYTHON} -m pip install . -vv --no-deps --no-build-isolation

install -m 644 include/qdalign.h "${PREFIX}/include/qdalign.h"
install -m 644 libdotmatch.a "${PREFIX}/lib/libdotmatch.a"
install -m 644 LICENSE "${PREFIX}/share/${PKG_NAME}/LICENSE"

if [[ "$(uname -s)" == "Darwin" ]]; then
  install -m 755 libdotmatch.dylib "${PREFIX}/lib/libdotmatch.dylib"
else
  install -m 755 libdotmatch.so "${PREFIX}/lib/libdotmatch.so"
fi
