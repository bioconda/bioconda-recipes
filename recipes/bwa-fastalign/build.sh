#!/bin/bash
set -ex

export CFLAGS="${CFLAGS} -g -Wall -Wno-unused-function -mavx2 -O3"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

mkdir -p "${PREFIX}/bin"

make CC="${CC}" CFLAGS="${CFLAGS}" \
    CPPFLAGS="${CPPFLAGS}" LDFLAGS="${LDFLAGS}" \
    -j"${CPU_COUNT}"

install -v -m 0755 bwa-fastalign "$PREFIX/bin"
