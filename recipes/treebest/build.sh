#!/bin/bash
set -e

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3 -fcommon"
export CXXFLAGS="${CXXFLAGS} -O3 -fcommon"

mkdir -p "$PREFIX/bin"

make CC="${CC}" CXX="${CXX}" CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" -j1

install -v -m 0755 treebest "$PREFIX/bin"
