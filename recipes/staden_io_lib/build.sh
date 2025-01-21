#!/bin/bash

export M4="${BUILD_PREFIX}/bin/m4"
export CFLAGS="${CFLAGS} -O3 -L${PREFIX}/lib -Wno-unused-command-line-argument"
export CPPFLAGS="${CPPFLAGS} -O3 -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

if [[ "$(uname)" == "Darwin" ]]; then
	export LDFLAGS="${LDFLAGS} -Wl,-rpath,${PREFIX}/lib"
fi

OS=$(uname)
ARCH=$(uname -m)

if [[ "${OS}" == "Darwin" && "${ARCH}" == "arm64" ]]; then
	export EXTRA_ARGS="--host=arm64"
elif [[ "${OS}" == "Linux" && "${ARCH}" == "aarch64" ]]; then
	export EXTRA_ARGS="--host=aarch64"
else
	export EXTRA_ARGS="--host=x86_64"
fi

cp -rf ${RECIPE_DIR}/config.* .

cd htscodecs
autoupdate
autoreconf -if

cd ..

autoupdate
autoreconf -if
./configure --prefix="${PREFIX}" --with-libdeflate="${PREFIX}" --with-libcurl="${PREFIX}" \
	--with-zlib="${PREFIX}" --with-zstd="${PREFIX}" --disable-warnings \
	--disable-dependency-tracking --disable-option-checkin --enable-silent-rules \
	--enable-shared=yes --enable-static=no LDFLAGS="${LDFLAGS}" CC="${CC}" CFLAGS="${CFLAGS}" \
	CPPFLAGS="${CPPFLAGS}" "${EXTRA_ARGS}"
make -j"${CPU_COUNT}"
make install

install -v -m 0755 io_lib_config.h "${PREFIX}/include/io_lib"
