#!/bin/bash -euo

set -xe

export CFLAGS="${CFLAGS} -I$PREFIX/include -O3"
export LDFLAGS="${LDFLAGS} -L$PREFIX/lib"
export CPATH="${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -I${PREFIX}/include -O3 -std=c++17 -Wno-braced-scalar-init"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"

autoreconf -if
./configure --prefix="${PREFIX}" CC="${CC}" CXX="${CXX}" \
  CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" \
  CPPFLAGS="${CPPFLAGS}" LDFLAGS="${LDFLAGS}" \
  --disable-dependency-tracking --disable-silent-rules

make -j ${CPU_COUNT}
make install

mkdir -p ${PREFIX}/bin
cp -rf ntsm-scripts ntsmSiteGen ${PREFIX}/bin
