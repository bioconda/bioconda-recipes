#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

mkdir -p "${PREFIX}/bin"
cd src
make \
  CC="${CC}" CXX="${CXX}" \
  CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" \
  LINK="${CXX}" LFLAGS="${LDFLAGS}" \
  TARGET="${PREFIX}/bin/prank" -j"${CPU_COUNT}"
