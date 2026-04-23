#!/bin/bash
set -eu

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include -Wno-unused-variable"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3 -std=c++14"
export CFLAGS="${CFLAGS} -O3"

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

cp -f ${BUILD_PREFIX}/share/gnuconfig/config.* .

autoreconf -if
./configure --prefix="${PREFIX}" CXX="${CXX}" CC="${CC}" \
	LDFLAGS="${LDFLAGS}" CPPFLAGS="${CPPFLAGS}" \
	CXXFLAGS="${CXXFLAGS}" CFLAGS="${CFLAGS}" \
	--with-snappy --with-io_lib \
	--with-libsecrecy --with-nettle \
	--with-lzma --with-gmp --with-parasail \
	--enable-shared-libmaus2 --disable-option-checking \
	--disable-dependency-tracking --enable-silent-rules

make clean

make -j"${CPU_COUNT}"
make install
