#!/bin/bash
set -xe

mkdir -p ${PREFIX}/bin

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3"

make CXX="${CXX}" INCLUDE="-I${PREFIX}/include -Ihtslib" RELEASEFLAGS="${CPPFLAGS} ${CXXFLAGS} ${LDFLAGS}" -j"${CPU_COUNT}"
install -v -m 0755 viral_consensus "${PREFIX}/bin"
