#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3"
export CXXFLAGS="${CXXFLAGS} -O3 -std=c++14"

case $(uname -m) in
    aarch64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8-a"
	;;
    arm64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8.4-a"
	;;
    x86_64)
	export CXXFLAGS="${CXXFLAGS} -march=x86-64-v3"
	;;
esac

install -d "${PREFIX}/bin"

if [[ "$(uname -m)" == "aarch64" || "$(uname -m)" == "arm64" ]]; then
	git clone https://github.com/DLTcollab/sse2neon.git
	cp -f sse2neon/sse2neon.h vendor/swsharp/swsharp/src/swimd/
	cp -f sse2neon/sse2neon.h vendor/swsharp/swsharp/src/ssw/
	sed -i.bak 's|#include <emmintrin.h>|#include "sse2neon.h"|' vendor/swsharp/swsharp/src/ssw/ssw.*
	sed -i.bak 's|#include <immintrin.h>|#include "sse2neon.h"|' vendor/swsharp/swsharp/src/swimd/Swimd.cpp
	rm -f vendor/swsharp/swsharp/src/ssw/*.bak
	rm -f vendor/swsharp/swsharp/src/swimd/*.bak
fi

make CC="${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}" \
	CP="${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS}" \
	-j"${CPU_COUNT}"

install -v -m 0755 bin/* "${PREFIX}/bin"
