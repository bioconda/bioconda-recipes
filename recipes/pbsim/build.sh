#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -O3 -I${PREFIX}/include -Wno-deprecated-declarations -Wno-implicit-function-declaration"
export CXXFLAGS="${CXXFLAGS} -O3 -Wno-deprecated-declarations -Wno-implicit-function-declaration"

cp -f ${BUILD_PREFIX}/share/gnuconfig/config.* .

autoreconf -fi
./configure --prefix="${PREFIX}" \
  CXX="${CXX}" \
  CXXFLAGS="${CXXFLAGS}" \
  CPPFLAGS="${CPPFLAGS}" \
  LDFLAGS="${LDFLAGS}" \
  --enable-silent-rules --disable-dependency-tracking --disable-option-checking

make -j"${CPU_COUNT}"
make install
