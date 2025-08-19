#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3 -Wno-deprecated-declarations"

cp -f ${BUILD_PREFIX}/share/gnuconfig/config.* .

autoreconf -if
./configure --prefix="${PREFIX}" \
	CC="${CC}" CFLAGS="${CFLAGS}" \
	CPPFLAGS="${CPPFLAGS}" LDFLAGS="${LDFLAGS}" \
	--enable-silent-rules --disable-dependency-tracking --disable-option-checking

make -j"${CPU_COUNT}"
make install
