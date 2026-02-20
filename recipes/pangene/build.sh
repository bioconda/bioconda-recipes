#!/bin/bash
set -xe

mkdir -p "$PREFIX/bin"

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3 -I${PREFIX}/include -Wno-implicit-function-declaration -Wno-int-conversion"

make CC="$CC" \
	CXX="${CXX}" \
	CFLAGS="$CFLAGS -std=c99 -g -Wall -O3" \
	INCLUDES="-I$PREFIX/include" \
	LIBS="-L${PREFIX}/lib -lm -lz -pthread" \
	-j"${CPU_COUNT}"

install -v -m 0755 pangene "$PREFIX/bin"
