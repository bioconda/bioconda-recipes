#!/bin/bash

set -xe

make -C src -j ${CPU_COUNT} BUILD_DIR="$(pwd)" \
	TARGET_DIR="${PREFIX}" \
	CXX="${CXX}" \
	CXXFLAGS="${CXXFLAGS} -O3 -I${PREFIX}/include" \
	LDFLAGS="${LDFLAGS} -fopenmp -L${PREFIX}/lib" -j"${CPU_COUNT}"
