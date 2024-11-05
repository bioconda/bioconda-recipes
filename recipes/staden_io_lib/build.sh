#!/bin/bash

export M4="${BUILD_PREFIX}/bin/m4"

./configure --prefix="${PREFIX}" \
	--with-libdeflate="${PREFIX}/lib" \
	CFLAGS="${CFLAGS} -O3" CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include" \
	LDFLAGS="${LDFLAGS} -L${PREFIX}/lib -Wl,-R${PREFIX}/lib"
make -j"${CPU_COUNT}"
make install

cp -f io_lib_config.h ${PREFIX}/include/io_lib/
