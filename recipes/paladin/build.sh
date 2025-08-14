#!/bin/bash

export C_INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3"

if [[ "$(uname -s)" == "Darwin" ]]; then
	make CC="${CC}" LIBS="${LDFLAGS} -lm -lz -pthread" INCLUDES="${CFLAGS}" -j"${CPU_COUNT}"
else
	make CC="${CC}" LIBS="${LDFLAGS} -lm -lz -pthread -lrt" INCLUDES="${CFLAGS}" -j"${CPU_COUNT}"
fi

install -m 0755 paladin "${PREFIX}/bin"
