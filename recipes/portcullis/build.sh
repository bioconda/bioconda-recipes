#!/bin/bash
set -x -e

export CFLAGS="$CFLAGS -O3"
export CPPFLAGS="$CPPFLAGS -I$PREFIX/include"
export CXXFLAGS="$CXXFLAGS -O3"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"

mkdir -p build-aux
cp -f ${BUILD_PREFIX}/share/gnuconfig/config.* build-aux/
cp -f ${BUILD_PREFIX}/share/gnuconfig/config.* .
cp -f ${BUILD_PREFIX}/share/gnuconfig/config.* deps/ranger-0.3.8/
cp -f ${BUILD_PREFIX}/share/gnuconfig/config.* deps/htslib-1.3/

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

autoreconf -if
./configure --enable-silent-rules \
	--disable-dependency-tracking \
	--disable-option-checking \
	--prefix="${PREFIX}" \
	--with-boost="${PREFIX}" \
	--with-boost-libdir="${PREFIX}/lib" \
	CC="${CC}" \
	CFLAGS="${CFLAGS}" \
	CXX="${CXX}" \
	CXXFLAGS="${CXXFLAGS}" \
	CPPFLAGS="${CPPFLAGS}" \
	LDFLAGS="${LDFLAGS}"

make -j"${CPU_COUNT}"
make -j"${CPU_COUNT}" check

make install
