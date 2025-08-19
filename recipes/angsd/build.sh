#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3"
export CXXFLAGS="${CXXFLAGS} -O3"

mkdir -p "${PREFIX}/bin"

cd angsd

sed -i.bak 's|-dm0755|-d|' Makefile
sed -i.bak 's|-m0755|-m 0755|' Makefile
rm -rf *.bak

# '-D__STDC_FORMAT_MACROS' fix from https://github.com/ANGSD/angsd/issues/397
make install-all \
	HTSSRC="systemwide" \
	CFLAGS="${CFLAGS}" \
	CPPFLAGS="${CPPFLAGS}" \
	prefix="${PREFIX}" \
	CC="${CC}" \
	CXX="${CXX}" \
	FLAGS="-I${PREFIX}/include -L${PREFIX}/lib -D__STDC_FORMAT_MACROS" \
	-j"${CPU_COUNT}"
