#!/bin/bash

set -xe

export CXXFLAGS="${CXXFLAGS} -O3"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

make CXX="${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS}" -j"${CPU_COUNT}"
install -d "${PREFIX}/bin"
install -v -m 0755 kmercamel "${PREFIX}/bin"
