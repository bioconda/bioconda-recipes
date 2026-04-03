#!/bin/bash
set -eu -o pipefail
set -x

export PKG_CONFIG_PATH=${PREFIX}/lib/pkgconfig:${PKG_CONFIG_PATH:-}
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

./configure --prefix="${PREFIX}" \
  CXX="${CXX}" LDFLAGS="${LDFLAGS}" CPPFLAGS="${CPPFLAGS}" \
  CXXFLAGS="${CXXFLAGS}" || cat config.log

make -j"${CPU_COUNT}"
make install
