#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"

cmake -S src -B build -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_CXX_COMPILER="${CXX}" \
  -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
  -Wno-dev -Wno-deprecated --no-warn-unused-cli
cmake --build build --clean-first -j "${CPU_COUNT}"

install -v -m 0755 build/main/taxor "${PREFIX}/bin"
