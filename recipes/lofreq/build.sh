#!/bin/bash
set -eu -o pipefail

export M4="${BUILD_PREFIX}/bin/m4"
export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3"

if [[ "$(uname -s)" == "Darwin" ]]; then
	export LDFLAGS="${LDFLAGS} -Wl,-rpath,${PREFIX}/lib"
fi

# use newer config.guess and config.sub that support osx-arm64
cp -rf ${BUILD_PREFIX}/share/gnuconfig/config.* .

autoreconf -if
./configure --with-htslib=system --prefix="${PREFIX}" \
	CC="${CC}" CFLAGS="${CFLAGS}" \
	LDFLAGS="${LDFLAGS}" \
	CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include" \
	PYTHON="${PYTHON}"

make -j"${CPU_COUNT}"
make install
