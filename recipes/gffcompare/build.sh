#!/bin/bash
set -xe

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3"

mkdir -p "$PREFIX/bin"

make release CXX="${CXX}" LINKER="${CXX}" -j"${CPU_COUNT}"

install -v -m 0755 gffcompare trmap "${PREFIX}/bin"
