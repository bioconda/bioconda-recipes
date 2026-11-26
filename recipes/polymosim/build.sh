#!/bin/bash
set -euxo pipefail

# The Makefile does not use CPPFLAGS, so they are passed with CXXFLAGS.
make \
  CXX="${CXX}" \
  CXXFLAGS="${CXXFLAGS} ${CPPFLAGS} -O3" \
  LDFLAGS="${LDFLAGS}" \
  -j"${CPU_COUNT}"

make install PREFIX="${PREFIX}"
