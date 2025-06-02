#!/bin/bash
set -xe

mkdir -p $PREFIX/bin
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPATH="${PREFIX}/include"

cd src
make CC="${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS} -fPIE" CXX="${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS} -fPIE" -j"${CPU_COUNT}"

install -v -m 0755 vamos ${PREFIX}/bin
