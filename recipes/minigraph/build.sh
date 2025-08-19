#!/bin/bash
set -xe

mkdir -p "$PREFIX/bin"

export C_INCLUDE_PATH="${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

make CC="${CC}" -j"${CPU_COUNT}"

install -v -m 0755 minigraph "$PREFIX/bin"
