#!/bin/bash

export M4="${BUILD_PREFIX}/bin/m4"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

if [[ "$(uname)" == "Darwin" ]]; then
	export LDFLAGS="${LDFLAGS} -Wl,-rpath,${PREFIX}/lib"
fi

cp -rf ${RECIPE_DIR}/config.* .

cd htscodecs
autoreconf -if

cd ..

autoreconf -if
./configure --prefix="${PREFIX}" --with-libdeflate="${PREFIX}" \
	--with-libcurl="${PREFIX}" --with-zlib="${PREFIX}" \
	--with-zstd="${PREFIX}" CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include" \
	LDFLAGS="${LDFLAGS}" CC="${CC}" CFLAGS="${CFLAGS} -O3 -L${PREFIX}/lib" \
	--disable-shared
make -j"${CPU_COUNT}"
make install

cp -f io_lib_config.h ${PREFIX}/include/io_lib/
