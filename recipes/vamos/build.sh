#!/bin/bash
set -xe

mkdir -p "${PREFIX}/bin"
export CFLAGS="${CFLAGS} -O3 -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPATH="${PREFIX}/include"

cd src
make CC="${CC} ${CFLAGS} ${LDFLAGS} -fPIE" CXX="${CXX} ${CXXFLAGS} ${LDFLAGS} -fPIE" -j"${CPU_COUNT}"

install -v -m 0755 vamos ${PREFIX}/bin
