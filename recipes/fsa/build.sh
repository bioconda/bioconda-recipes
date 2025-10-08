#!/bin/bash

export CFLAGS="${CFLAGS} -O3"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"

mkdir -p "$PREFIX/bin"

cp -f ${BUILD_PREFIX}/share/gnuconfig/config.* build-aux/

case $(uname -m) in
    aarch64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8-a"
	sed -i.bak 's|-m64||' configure.ac && rm -f *.bak
	;;
    arm64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8.4-a"
	sed -i.bak 's|-m64||' configure.ac && rm -f *.bak
	;;
    x86_64)
	export CXXFLAGS="${CXXFLAGS} -march=x86-64-v3"
	;;
esac

./configure --prefix="${PREFIX}" \
	--disable-option-checking --enable-silent-rules --disable-dependency-tracking \
	--with-mummer=yes \
	--with-exonerate=yes \
	CC="${CC}" \
	CFLAGS="${CFLAGS}" \
	CXX="${CXX}" \
	CXXFLAGS="${CXXFLAGS}" \
	CPPFLAGS="${CPPFLAGS}" \
	LDFLAGS="${LDFLAGS}"

make
make install
