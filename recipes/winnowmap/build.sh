#!/bin/bash

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3"
export CFLAGS="${CFLAGS} -O3 -Wno-narrowing"

install -d "${PREFIX}/bin"

case $(uname -m) in
	aarch64|arm64) sed -i.bak 's|-msse2||' src/Makefile && sed -i.bak 's|-mno-sse4.1||' src/Makefile && sed -i.bak 's|-msse4.1||' src/Makefile ;;
esac

sed -i.bak 's|-lpthread|-pthread|' Makefile
sed -i.bak 's|-O2|-O3|' Makefile
rm -rf *.bak
rm -rf src/*.bak

case $(uname -m) in
	aarch64|arm64) make CC="${CC}" CXX="${CXX}" CPPFLAGS="${CXXFLAGS} ${CPPFLAGS} -g -Wall -O3 -DHAVE_KALLOC -fopenmp -std=c++14 -Wno-sign-compare -Wno-write-strings -Wno-unused-but-set-variable -Wno-narrowing ${LDFLAGS}" arm_neon=1 -j"${CPU_COUNT}" ;;
	*) make CC="${CC}" CXX="${CXX}" CPPFLAGS="${CXXFLAGS} ${CPPFLAGS} -g -Wall -O3 -DHAVE_KALLOC -fopenmp -std=c++14 -Wno-sign-compare -Wno-write-strings -Wno-unused-but-set-variable ${LDFLAGS}" -j"${CPU_COUNT}" ;;
esac

install -v -m 0755 bin/winnowmap "${PREFIX}/bin"
