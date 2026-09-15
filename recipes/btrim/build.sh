#!/bin/bash

mkdir -p "${PREFIX}/bin"

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"

make CC="${CXX}" \
	CFLAGS="${CXXFLAGS} -Wall -Wextra  -Ofast -std=c++11  -pthread -pipe -fopenmp" \
	LDFLAGS="${LDFLAGS} -pthread -fopenmp"

install -v -m 0755 btrim "${PREFIX}/bin"
