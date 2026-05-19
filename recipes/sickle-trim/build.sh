#!/bin/bash
set -xe

mkdir -p "$PREFIX/bin"

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3 -Wall -pedantic -I${PREFIX}/include -DVERSION=${PKG_VERSION}"

make CC="${CC}" CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" -j"${CPU_COUNT}"

install -v -m 0755 sickle "$PREFIX/bin"
