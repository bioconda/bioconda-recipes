#!/bin/bash

set -eux

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

autoreconf -if
./configure --prefix="${PREFIX}" \
	CXX="${CXX}" \
	CXXFLAGS="${CXXFLAGS} -O3 -I${PREFIX}/include" \
	LDFLAGS="${LDFLAGS}"
make -j "${CPU_COUNT}"
make install
