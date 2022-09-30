#!/bin/bash

make \
  CC="${CXX}" \
  CFLAGS="${CXXFLAGS} -Wall -Wextra  -Ofast -std=c++11  -pthread -pipe -fopenmp" \
  LDFLAGS="${LDFLAGS} -pthread -fopenmp"

mkdir -p "${PREFIX}/bin"
cp btrim "${PREFIX}/bin/"
