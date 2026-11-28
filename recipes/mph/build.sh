#!/bin/bash

set -eux -o pipefail

export CXXFLAGS="${CXXFLAGS} -O3 -std=c++11 -fopenmp -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export MKL_THREADING_LAYER="GNU"

make \
  CXX="${CXX}" \
  CXXFLAGS="${CXXFLAGS}" \
  INCLUDES="-I${PREFIX}/include/eigen3" \
  LDFLAGS="${LDFLAGS}" \
  LDLIBS="-lmkl_rt -lgomp -lpthread -lm -ldl" \
  -j"${CPU_COUNT}"

install -d "${PREFIX}/bin"
install -m 0755 mph "${PREFIX}/bin/mph"
