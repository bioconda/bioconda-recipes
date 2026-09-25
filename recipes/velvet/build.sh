#!/bin/bash
set -xe

mkdir -p "${PREFIX}/bin"

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3 -I${PREFIX}/include -Wno-implicit-function-declaration -Wno-int-conversion"

make CC="${CC}" CFLAGS="${CFLAGS}" 'CATEGORIES=4' 'MAXKMERLENGTH=191' 'OPENMP=1' 'LONGSEQUENCES=1' -j"${CPU_COUNT}"

install -v -m 0755 velvetg velveth "${PREFIX}/bin"
