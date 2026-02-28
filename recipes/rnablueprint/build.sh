#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3 -Wno-deprecated-declarations"
export CXXFLAGS="${CXXFLAGS} -O3 -Wno-maybe-uninitialized -Wno-unused-result -Wno-register"
export BOOST_ROOT="${PREFIX}"

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

autoreconf -if
./configure --prefix="${PREFIX}" \
	--enable-libGMP \
	--with-boost="${PREFIX}" \
	--disable-option-checking --enable-silent-rules --disable-dependency-tracking \
	CC="${CC}" \
	CFLAGS="${CFLAGS}" \
	CXX="${CXX}" \
	CXXFLAGS="${CXXFLAGS}" \
	CPPFLAGS="${CPPFLAGS}" \
	LDFLAGS="${LDFLAGS}" \
	BOOST_ROOT="${PREFIX}"

make -j"${CPU_COUNT}"
make install
