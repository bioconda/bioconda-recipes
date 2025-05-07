#!/bin/bash
set -xe

mkdir -p "${PREFIX}/bin"

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"

make CXX="${CXX}" CXXFLAGS="${CXXFLAGS} -std=c++03" \
	-j"${CPU_COUNT}"
install -v -m 0755 snap-aligner "${PREFIX}/bin"
