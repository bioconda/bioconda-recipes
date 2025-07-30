#!/bin/bash
set -eu -o pipefail

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3"
export CXXFLAGS="${CXXFLAGS} -O3"

mkdir -p "${PREFIX}/bin"

if [[ "$(uname -s)" == "Darwin"  ]] && [[ "$(uname -m)" == "arm64" ]]; then
  sed -i.bak 's|-static|-static -O3 -march=armv8.4-a|' applications/bed/starch/src/Makefile
fi

make all CC="${CC}" CXX="${CXX}" SFLAGS= -j"${CPU_COUNT}"
make install_all

install -v -m 0755 bin/* "${PREFIX}/bin"
