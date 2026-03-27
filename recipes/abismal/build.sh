#!/bin/bash

export M4="${BUILD_PREFIX}/bin/m4"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3 -D_LIBCPP_DISABLE_AVAILABILITY"

autoreconf -if
./configure --prefix="${PREFIX}" \
  --disable-option-checking --enable-silent-rules --disable-dependency-tracking \
  CXX="${CXX}" LDFLAGS="${LDFLAGS}" CPPFLAGS="${CPPFLAGS}" \
  CXXFLAGS="${CXXFLAGS}"

make CXXFLAGS="${CXXFLAGS}" -j"${CPU_COUNT}"
make install
