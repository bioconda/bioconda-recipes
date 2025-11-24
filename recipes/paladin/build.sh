#!/bin/bash

export C_INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3"

mkdir -p "${PREFIX}/bin"

sed -i.bak 's|-O2|-O3|' Makefile
sed -i.bak 's|-lpthread|-pthread|' Makefile
sed -i.bak 's|AR=|#AR=|' Makefile
sed -i.bak 's|-csru|-rcs|' Makefile

case $(uname -m) in
    aarch64|arm64)
		git clone https://github.com/DLTcollab/sse2neon.git
		cp -f sse2neon/sse2neon.h .
		
        sed -i.bak 's|#include <emmintrin.h>|#include "sse2neon.h"|' ksw.c
        ;;
esac
rm -f *.bak

if [[ "$(uname -s)" == "Darwin" ]]; then
	make CC="${CC}" LIBS="${LDFLAGS} -lm -lz -pthread" INCLUDES="-I${PREFIX}/include" -j"${CPU_COUNT}"
else
	make CC="${CC}" LIBS="${LDFLAGS} -lm -lz -pthread -lrt" INCLUDES="-I${PREFIX}/include" -j"${CPU_COUNT}"
fi

install -m 0755 paladin "${PREFIX}/bin"
