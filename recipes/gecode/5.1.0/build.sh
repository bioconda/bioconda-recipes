#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I$PREFIX/include"
export CFLAGS="${CFLAGS} -O3"
export CXXFLAGS="${CXXFLAGS} -O3 -Wno-deprecated-declarations -Wno-maybe-uninitialized -Wno-unused-result -Wno-register -Wno-unknown-warning-option"
export LC_ALL=C

cp -f ${BUILD_PREFIX}/share/gnuconfig/config.* .

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

./configure --prefix="${PREFIX}" \
	--disable-qt \
	--disable-option-checking \
	CXX="${CXX}" \
	CXXFLAGS="${CXXFLAGS}" \
	CFLAGS="${CFLAGS}"

sed -i'.bak' 's|-lmpfr  -lgmp|-L$(PREFIX)/lib  -lmpfr  -lgmp|' Makefile
rm -f *.bak

make -j"${CPU_COUNT}"
make install
