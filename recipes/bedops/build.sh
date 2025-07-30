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

if [[ "$(uname -s)" == "Darwin"  ]]; then
  sed -i.bak 's|-static||' applications/bed/starch/src/Makefile
  make all CC="${CC}" CXX="${CXX}" -j"${CPU_COUNT}"
else
  make all CC="${CC}" CXX="${CXX}" SFLAGS="-static -O3" -j"${CPU_COUNT}"
fi

make install_all

install -v -m 0755 bin/* "${PREFIX}/bin"
