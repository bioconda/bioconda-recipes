#!/bin/bash -euo

mkdir -p ${PREFIX}/bin

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

make CC="${CC} ${LDFLAGS}" CFLAGS="${CFLAGS} -O3" LIBDIR="-L${PREFIX}/lib" \
	INCLUDE="-I${PREFIX}/include" -j"${CPU_COUNT}"

chmod 755 pTrimmer
mv pTrimmer ${PREFIX}/bin/ptrimmer
