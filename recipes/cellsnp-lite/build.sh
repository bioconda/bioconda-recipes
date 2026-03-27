#!/bin/bash

mkdir -p "${PREFIX}/bin"

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -g -Wall -O3 -Wno-implicit-function-declaration"

autoreconf -if
./configure --prefix="${PREFIX}" CC="${CC}" CFLAGS="${CFLAGS}" \
	LDFLAGS="${LDFLAGS}" CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include" \
	--disable-option-checking --enable-silent-rules --disable-dependency-tracking

make -j"${CPU_COUNT}"
make install
