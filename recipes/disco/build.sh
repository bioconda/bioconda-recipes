#!/bin/bash
set -eo pipefail

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3"
export LC_ALL="en_US.UTF-8"

mkdir -p "${PREFIX}/bin"

make clean
make all \
	CC="mpic++ ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS}" \
	CXX="${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS}" \
	READGZ=1 -j"${CPU_COUNT}"

install -v -m 0755 buildG* \
	fullsimplify \
	parsimplify \
	disco* \
	run* \
	"${PREFIX}/bin"
