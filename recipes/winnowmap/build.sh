#!/bin/bash

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3"

install -d "${PREFIX}/bin"

make \
	CPPFLAGS="${CXXFLAGS} ${CPPFLAGS} -g -Wall -O3 -DHAVE_KALLOC -fopenmp -std=c++14 -Wno-sign-compare -Wno-write-strings -Wno-unused-but-set-variable ${LDFLAGS}" \
	-j"${CPU_COUNT}"

install -v -m 0755 bin/winnowmap "${PREFIX}/bin"
