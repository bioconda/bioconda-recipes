#!/bin/bash
set -xe

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3"

install -d "${PREFIX}/bin"

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

case $(uname -m) in
    aarch64|arm64)
	sed -i.bak 's|-m64||' Makefile
	sed -i.bak 's|-msse2||' Makefile
	rm -f *.bak

	git clone https://github.com/DLTcollab/sse2neon.git
	cp -f sse2neon/sse2neon.h src/
	cp -f sse2neon/sse2neon.h src/distanceCalculation/
	sed -i.bak 's|#include <emmintrin.h>|#include "sse2neon.h"|' src/stdinclude.h
	rm -f src/*.bak
	sed -i.bak 's|#include <emmintrin.h>|#include "sse2neon.h"|' src/distanceCalculation/bitDistanceProtein.cpp
	rm -f src/distanceCalculation/*.bak
	;;
esac

make -j"${CPU_COUNT}" CC="${CXX}" LINK="${CXX}" SWITCHES="${CPPFLAGS} ${CXXFLAGS} ${LDFLAGS}"

install -v -m 0755 bin/rapidnj "${PREFIX}/bin"
