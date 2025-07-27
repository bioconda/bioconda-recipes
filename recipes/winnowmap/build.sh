#!/bin/bash

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3"

install -d "${PREFIX}/bin"

case $(uname -m) in
	aarch64|arm64) make CC="${CC}" CXX="${CXX}" CPPFLAGS="${CXXFLAGS} ${CPPFLAGS} -g -Wall -O3 -DHAVE_KALLOC -fopenmp -std=c++14 -Wno-sign-compare -Wno-write-strings -Wno-unused-but-set-variable ${LDFLAGS}" arm_neon=1 -j"${CPU_COUNT}" ;;
esac

make CC="${CC}" CXX="${CXX}" \
	CPPFLAGS="${CXXFLAGS} ${CPPFLAGS} -g -Wall -O3 -DHAVE_KALLOC -fopenmp -std=c++14 -Wno-sign-compare -Wno-write-strings -Wno-unused-but-set-variable ${LDFLAGS}" \
	-j"${CPU_COUNT}"

install -v -m 0755 bin/winnowmap "${PREFIX}/bin"
