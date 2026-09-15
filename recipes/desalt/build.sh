#!/bin/bash
set -xe

export CFLAGS="${CFLAGS} -fcommon -g -Wall -O3 -Wc++-compat -L$PREFIX/lib -fopenmp -Wno-implicit-function-declaration -Wno-unused-variable"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

mkdir -p "$PREFIX/bin"

if [[ "$(uname -m)" == "aarch64" || "$(uname -m)" == "arm64" ]]; then
	git clone https://github.com/DLTcollab/sse2neon.git
 	cp -f sse2neon/sse2neon.h src/
	sed -i.bak 's|#include <emmintrin.h>|#include "sse2neon.h"|' src/ksw2_ll_sse.c
	sed -i.bak 's|#undef __SSE4_1__|#include "sse2neon.h"|' src/ksw2_extz2_sse.c
	sed -i.bak 's|#undef __SSE4_1__|#include "sse2neon.h"|' src/ksw2_extd2_sse.c
	sed -i.bak 's|#undef __SSE4_1__|#include "sse2neon.h"|' src/ksw2_exts2_sse.c
	sed -i.bak 's|#include <emmintrin.h>|#include "sse2neon.h"|' src/ksw2_ext?2_sse.c
	#sed -i.bak 's|#include <smmintrin.h>|#include "sse2neon.h"|' src/ksw2_ext?2_sse.c
  	rm -f src/*.bak
fi

case $(uname -m) in
	aarch64|arm64) sed -i.bak 's|-msse2||' src/Makefile && sed -i.bak 's|-mno-sse4.1||' src/Makefile && sed -i.bak 's|-msse4.1||' src/Makefile ;;
esac

cd src

#malloc.h is a Linux-ism
sed -i.bak "s/malloc.h/stdlib.h/" load_unipath_size.c
sed -i.bak "s/malloc.h/stdlib.h/" graph.c
sed -i.bak "s/malloc.h/stdlib.h/" deBGA-master/load_input.c
sed -i.bak "s/malloc.h/stdlib.h/" deBGA-master/index_build.c
rm -f *.bak

case $(uname -m) in
	aarch64|arm64) make INCLUDES="-I$PREFIX/include" CFLAGS="${CFLAGS}" LIBS="-lm -lz -pthread" arm_neon=1 -j"${CPU_COUNT}";;
	*) make INCLUDES="-I$PREFIX/include" CFLAGS="${CFLAGS}" LIBS="-lm -lz -pthread" -j"${CPU_COUNT}";;
esac

install -v -m 0755 deSALT deBGA Annotation_Load.py "$PREFIX/bin"
