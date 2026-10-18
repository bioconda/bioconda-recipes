#!/bin/bash
set -eu -o pipefail

export CFLAGS="${CFLAGS} -O3"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

OS=$(uname -s)
ARCH=$(uname -m)

if [[ "${ARCH}" == "aarch64" || "${ARCH}" == "arm64" ]]; then
	export EXTRA_ARGS="--enable-neon"
else
	export EXTRA_ARGS="--enable-sse4"
fi

autoreconf -if
./configure --prefix="${PREFIX}" --disable-option-checking \
	--disable-debugging --enable-threads --enable-mpi \
	--with-gsl CC="${CC}" CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" \
	CPPFLAGS="${CPPFLAGS}" "${EXTRA_ARGS}"

make -j"${CPU_COUNT}"
make install
