#!/bin/bash
set -eu -o pipefail

export M4="${BUILD_PREFIX}/bin/m4"
export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3"

if [[ "$(uname)" == Darwin ]]; then
	export LDFLAGS="${LDFLAGS} -Wl,-rpath,${PREFIX}/lib"
fi

autoreconf -if
./configure --with-htslib=system --prefix="${PREFIX}" \
	CC="${CC}" CFLAGS="${CFLAGS}" \
	LDFLAGS="${LDFLAGS}" \
	CPPFLAGS="${CPPFLAGS} -O3 -I${PREFIX}/include" \
	PYTHON="${PYTHON}"

make -j"${CPU_COUNT}"
make install
