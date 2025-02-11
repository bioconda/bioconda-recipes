#!/bin/bash

mkdir -p ${PREFIX}/bin

export M4="$BUILD_PREFIX/bin/m4"
export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -g -Wall -O3 -Wno-implicit-function-declaration"

autoreconf -if
./configure --prefix="${PREFIX}" CC="${CC}" CFLAGS="${CFLAGS}" \
	LDFLAGS="${LDFLAGS}" CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"

make -j"${CPU_COUNT}"
make install

chmod 0755 ${PREFIX}/bin/cellsnp-lite
