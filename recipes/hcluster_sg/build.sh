#!/bin/bash
set -e

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3"

mkdir -p "$PREFIX/bin"

make CXX="${CXX}" CFLAGS="${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS}" -j"${CPU_COUNT}"

install -v -m 0755 hcluster_sg "$PREFIX/bin"
