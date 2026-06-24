#!/bin/bash

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3"

mkdir -p "${PREFIX}/bin"

sed -i.bak "s|-Ispoa/include|-Ispoa/include -L${PREFIX}/lib|" Makefile && rm -f *.bak

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
    aarch64)
	sed -i.bak 's|-march=x86-64-v3|-march=armv8-a|' Makefile && rm -f *.bak
	;;
    arm64)
	sed -i.bak 's|-march=x86-64-v3|-march=armv8.4-a|' Makefile && rm -f *.bak
	;;
esac

if [[ "$(uname -m)" == "aarch64" || "$(uname -m)" == "arm64" ]]; then
	git clone https://github.com/DLTcollab/sse2neon.git
	cp -f sse2neon/sse2neon.h spoa/src/
	sed -i.bak 's|#include <immintrin.h>|#include "sse2neon.h"|' spoa/src/simd_alignment_engine.cpp
	rm -f spoa/src/*.bak
fi

if [[ `uname -s` == "Darwin" ]]; then
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
	export CONFIG_ARGS=""
fi

cd spoa
rm -rf build

cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
	-Wno-dev -Wno-deprecated --no-warn-unused-cli \
	"${CONFIG_ARGS}"
cmake --build build -j "${CPU_COUNT}"

cd ..

make -j"${CPU_COUNT}"

install -v -m 0755 rattle "${PREFIX}/bin"
