#!/bin/bash

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

mkdir -p "${PREFIX}/bin"

cp -f ${BUILD_PREFIX}/share/gnuconfig/config.* config/

autoreconf -if
./configure --prefix="${PREFIX}" --enable-igzip \
	--disable-option-checking --enable-silent-rules \
	--disable-dependency-tracking \
	CC="${CC}" CFLAGS="${CFLAGS}" \
	LDFLAGS="${LDFLAGS}" CPPFLAGS="${CPPFLAGS}"

make -j"${CPU_COUNT}"
make install
