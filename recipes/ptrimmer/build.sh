#!/bin/bash

mkdir -p ${PREFIX}/bin

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

make CC="${CC}" CFLAGS="${CFLAGS} -O3" LIBDIR="${PREFIX}/lib" \
	INCLUDE="${PREFIX}/include" LDFLAGS="${LDFLAGS}" -j"${CPU_COUNT}"

chmod 755 pTrimmer-*
mv pTrimmer-* ${PREFIX}/bin/ptrimmer
