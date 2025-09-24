#!/bin/bash

export CPATH="${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L$PREFIX/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3"
export CXXFLAGS="${CXXFLAGS} -O3 -Wno-array-bounds -Wno-vla-cxx-extension"

autoreconf -if
./configure --prefix="${PREFIX}" \
	--disable-option-checking --enable-silent-rules \
	--disable-dependency-tracking CC="${CC}" CXX="${CXX}" \
	CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" CPPFLAGS="${CPPFLAGS}" \
	LDFLAGS="${LDFLAGS}"

make -j"${CPU_COUNT}"
make install
