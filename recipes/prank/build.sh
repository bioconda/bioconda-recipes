#!/bin/bash

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

mkdir -p ${PREFIX}/bin

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

sed -i.bak 's|-I/usr/include|-I$(PREFIX)/include|' src/Makefile
rm -f src/*.bak

cd src

make CC="${CC}" CXX="${CXX}" \
	CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" \
	LINK="${CXX}" LFLAGS="${LDFLAGS}" \
	TARGET="${PREFIX}/bin/prank" -j"${CPU_COUNT}"
