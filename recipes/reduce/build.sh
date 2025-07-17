#!/bin/bash

set -exo pipefail

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"

# Refer to https://github.com/rlabduke/reduce/issues/60 for `-DHET_DICTIONARY` and `-DHET_DICTOLD` flags
cmake -S . -B build \
  ${CMAKE_ARGS} \
  -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
  -DHET_DICTIONARY="${PREFIX}/reduce_wwPDB_het_dict.txt" \
  -DHET_DICTOLD="${PREFIX}/reduce_get_dict.txt"
cmake --build build --target install -j "${CPU_COUNT}"
