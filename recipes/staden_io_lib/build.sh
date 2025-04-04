#!/bin/bash

export M4="${BUILD_PREFIX}/bin/m4"
export CFLAGS="${CFLAGS} -O3 -Wno-unused-command-line-argument -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -O3 -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

if [[ "$(uname)" == "Darwin" ]]; then
	export LDFLAGS="${LDFLAGS} -Wl,-rpath,${PREFIX}/lib"
fi

cp -rf ${RECIPE_DIR}/config.* .

cd htscodecs
autoupdate
autoreconf -if
./configure --prefix="${PREFIX}" "${EXTRA_ARGS}" --enable-static --disable-shared \
	--disable-warnings --disable-dependency-tracking --disable-option-checkin --enable-silent-rules \
 	LDFLAGS="${LDFLAGS}" CC="${CC}" CFLAGS="${CFLAGS}" CPPFLAGS="${CPPFLAGS}" --target="${CC}"

cd ..

autoupdate
autoreconf -if
./configure --prefix="${PREFIX}" --with-libdeflate="${PREFIX}" --with-libcurl="${PREFIX}" \
	--with-zlib="${PREFIX}" --with-zstd="${PREFIX}" "${EXTRA_ARGS}" --enable-shared --disable-static \
 	--disable-warnings --disable-dependency-tracking --disable-option-checkin --enable-silent-rules \
	LDFLAGS="${LDFLAGS}" CC="${CC}" CFLAGS="${CFLAGS}" CPPFLAGS="${CPPFLAGS}" --target="${CC}"
make -j"${CPU_COUNT}"
make install

install -v -m 0755 io_lib_config.h "${PREFIX}/include/io_lib"
