#!/bin/bash

export CPPFLAGS="${LDFLAGS} -I${PREFIX}/include -DHAVE_KALLOC"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -g -O3 -Wc++-compat"

install -d "${PREFIX}/bin"

if [[ "$(uname -m)" == "aarch64" || "$(uname -m)" == "arm64" ]]; then
	export EXTRA_ARGS="arm_neon=1"
	git clone https://github.com/DLTcollab/sse2neon.git
	cp -f sse2neon/sse2neon.h .
	sed -i.bak 's|#include <emmintrin.h>|#include "sse2neon.h"|' ksw2_ll_sse.c
	sed -i.bak 's|#include <emmintrin.h>|#include "sse2neon.h"|' ksw2_ext?2_sse.c
else
	export EXTRA_ARGS=""
fi

case $(uname -m) in
	aarch64|arm64) sed -i.bak 's|-msse2||' Makefile && sed -i.bak 's|-mno-sse4.1||' Makefile && sed -i.bak 's|-msse4.1||' Makefile;;
esac

make CC="${CC}" \
	CFLAGS="${CFLAGS}" \
	CPPFLAGS="${CPPFLAGS}" \
	LIBS="-lm -lz -pthread" \
	"${EXTRA_ARGS}" \
	-j"${CPU_COUNT}"

install -v -m 0755 unimap "${PREFIX}/bin"
