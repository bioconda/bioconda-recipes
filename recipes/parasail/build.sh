#!/usr/bin/env bash

set -euo pipefail

export M4="$(command -v m4)"

autoreconf -fvi

./configure \
    --prefix="${PREFIX}" \
    --with-zlib \
    CC="${CC}" \
    CXX="${CXX}" \
    CFLAGS="${CFLAGS}" \
    CXXFLAGS="${CXXFLAGS}" \
    LDFLAGS="${LDFLAGS}"

make -j${CPU_COUNT}
make install
