#!/bin/bash

export M4="${BUILD_PREFIX}/bin/m4"

autoreconf -if
./configure --prefix="${PREFIX}" \
	--enable-shared=no --without-libcurl \
	--with-libdeflate="${PREFIX}" \
	LDFLAGS="${LDFLAGS} -L${PREFIX}/lib -Wl,-R${PREFIX}/lib -Wl,-rpath -Wl,${PREFIX}/lib"
make -j"${CPU_COUNT}"
make install

mv io_lib_config.h ${PREFIX}/include/io_lib/
