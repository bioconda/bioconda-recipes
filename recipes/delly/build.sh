#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"

make CXX="${CXX}" prefix="${PREFIX}" \
	CXXFLAGS="${CXXFLAGS} -D__STDC_FORMAT_MACROS" \
	-j"${CPU_COUNT}" install
