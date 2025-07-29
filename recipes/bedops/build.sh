#!/bin/bash
set -eu -o pipefail

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3"
export CXXFLAGS="${CXXFLAGS} -O3"

mkdir -p "$PREFIX/bin"

make all CC="${CC}" CXX="${CXX}" SFLAGS= -j"${CPU_COUNT}"
make install_all

install -v -m 0755 bin/* "$PREFIX/bin"
