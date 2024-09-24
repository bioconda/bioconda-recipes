#!/bin/bash

set -eu

./configure --prefix="${PREFIX}" CXX="${CXX}" \
	CXXFLAGS="${CXXFLAGS} -O3 -I${PREFIX}/include" \
	LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
make install
