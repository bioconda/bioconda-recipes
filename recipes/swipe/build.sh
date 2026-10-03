#!/bin/bash

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3"

install -d "${PREFIX}/bin"

make CXX="${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS}" -j"${CPU_COUNT}"

install -v -m 0755 swipe "${PREFIX}/bin"
