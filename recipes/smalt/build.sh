#!/bin/bash
set -xef -o pipefail

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3 -Wno-implicit-function-declaration"

cp -f ${RECIPE_DIR}/config.* .

autoconf
./configure --prefix="${PREFIX}" \
	--disable-option-checking --disable-dependency-tracking \
	CC="${CC}" \
	CFLAGS="${CFLAGS}" \
	CPPFLAGS="${CPPFLAGS}" \
	LDFLAGS="${LDFLAGS}"

make -j"${CPU_COUNT}"
make install
