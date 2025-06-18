#!/bin/bash
set -exo pipefail

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3"
export CXXFLAGS="${CXXFLAGS} -O3"

cp -f ${BUILD_PREFIX}/share/gnuconfig/config.* build-aux/

autoreconf -if
./configure \
	--prefix="${PREFIX}" \
	--enable-shared \
	--disable-static \
	--disable-debug \
	--disable-dependency-tracking \
	--enable-silent-rules \
	--disable-option-checking \
	CC="${CC}" CFLAGS="${CFLAGS}" \
	CPPFLAGS="${CPPFLAGS}" LDFLAGS="${LDFLAGS}" \
	CXX="${CXX}" CXXFLAGS="${CXXFLAGS}"

make -j"${CPU_COUNT}"
make install
