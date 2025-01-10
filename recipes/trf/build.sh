#!/bin/bash

export M4="${BUILD_PREFIX}/bin/m4"

autoreconf -if
./configure --prefix="${PREFIX}" CC="${CC}" CFLAGS="${CFLAGS} -O3" \
	CPPFLAGS="${CPPFLAGS} -DUNIXCONSOLE -I${PREFIX}/include" \
	LDFLAGS="${LDFLAGS} -I${PREFIX}/lib"

make -j"${CPU_COUNT}"
make install
