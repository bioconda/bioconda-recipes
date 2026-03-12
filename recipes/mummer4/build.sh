#!/bin/bash

set -xe

export M4="${BUILD_PREFIX}/bin/m4"
export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3 -Wno-deprecated-declarations"
export CXXFLAGS="${CXXFLAGS} -O3 -I${PREFIX}/include"

autoreconf -if
./configure --prefix="${PREFIX}" CC="${CC}" CXX="${CXX}" \
	CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" \
	CPPFLAGS="${CPPFLAGS} -O3 -I${PREFIX}/include" \
	LDFLAGS="${LDFLAGS}" YAGGO="$(which yaggo)" --enable-swig \
	--enable-python-binding --disable-option-checking \
	--enable-silent-rules --disable-dependency-tracking

make -j"${CPU_COUNT}"
make install
