#!/bin/bash
set -eu

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include -Wno-unused-variable -Wno-unused-but-set-variable"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3 -std=c++17 -Wno-unused-variable -Wno-unused-but-set-variable"
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

autoreconf -if;
./configure --prefix="${PREFIX}" CXX="${CXX}" CC="${CC}" \
	LDFLAGS="${LDFLAGS}" CPPFLAGS="${CPPFLAGS}" \
	CXXFLAGS="${CXXFLAGS}" CFLAGS="${CFLAGS}" \
	CPPFLAGS="${CPPFLAGS}" LDFLAGS="${LDFLAGS}" \
	--with-libmaus2="${PREFIX}/include" \
	--with-xerces-c="${PREFIX}/include" \
	--with-gmp --enable-fast --enable-install-uncommon \
	--disable-option-checking --enable-silent-rules --disable-dependency-tracking

make clean

make install -j"${CPU_COUNT}"

"${STRIP}" ${PREFIX}/bin/bio*
