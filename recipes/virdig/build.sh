#!/bin/bash
set -xe

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

rm -rf virdig
make virdig CXX="${CXX}" \
	CXXFLAGS="${CXXFLAGS} -g -Wall -O3 -I$PREFIX/include -Wno-unused-variable -Wno-return-type" \
	-j"${CPU_COUNT}"

install -d "${PREFIX}/bin"
install -v -m 0755 virdig "${PREFIX}/bin"
