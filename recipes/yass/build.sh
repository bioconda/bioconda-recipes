#!/bin/bash

export CFLAGS="${CFLAGS} -O3"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"

cp -f ${BUILD_PREFIX}/share/gnuconfig/config.* .

autoreconf -if
./configure --prefix="${PREFIX}" \
	--with-threads \
	CC="${CC}" \
	CFLAGS="${CFLAGS}" \
	CPPFLAGS="${CPPFLAGS}" \
	LDFLAGS="${LDFLAGS}" \
	--disable-option-checking \
	--disable-dependency-tracking \
	--enable-silent-rules

make -j"${CPU_COUNT}"
make install
