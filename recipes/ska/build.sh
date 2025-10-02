#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib -lz"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"

install -d ${PREFIX}/bin

make CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" LDFLAGS="${LDFLAGS}" -j"${CPU_COUNT}"

install -v -m 0755 bin/ska "${PREFIX}/bin"
