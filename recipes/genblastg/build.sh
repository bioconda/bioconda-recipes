#!/bin/sh

mkdir -p "${PREFIX}/bin"

make \
  CC="${CC}" CXX="${CXX}" \
  CPPFLAGS="${CPPFLAGS}" CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" \
  LDFLAGS="${LDFLAGS}" \
  PROGRAM="${PREFIX}/bin/genblastG" \
  all
