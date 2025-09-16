#!/bin/bash
set -xe

mkdir -p "${PREFIX}/bin"
export CFLAGS="${CFLAGS} -O3 -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

make BeEM CC="${CXX}" CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" -j"${CPU_COUNT}"

install -v -m 0755 BeEM "${PREFIX}/bin"
