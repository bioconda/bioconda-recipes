#!/bin/bash
set -euxo pipefail

make \
  CXX="${CXX}" \
  CXXFLAGS="${CXXFLAGS} -O3" \
  CPPFLAGS="${CPPFLAGS}" \
  LDFLAGS="${LDFLAGS}" \
  OPENMP=1 \
  -j"${CPU_COUNT}"

make install PREFIX="${PREFIX}"
