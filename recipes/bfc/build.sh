#!/bin/bash

mkdir -p "${PREFIX}/bin"

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3 -I${PREFIX}/include -Wno-implicit-function-declaration -Wno-int-conversion"

LIBS="${LDFLAGS}" make CC="${CC}" CFLAGS="${CFLAGS}" CPPFLAGS="${CPPFLAGS}" -j"${CPU_COUNT}"

install -v -m 0755 bfc "${PREFIX}/bin"
