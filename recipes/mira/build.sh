#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I$PREFIX/include -Wno-maybe-uninitialized"
export CFLAGS="${CFLAGS} -O3 -Wno-deprecated-declarations -Wno-unused-result -Wno-maybe-uninitialized"
export CXXFLAGS="${CXXFLAGS} -O3 -Wno-maybe-uninitialized"

mkdir -p "${PREFIX}/bin"

cp -f ${BUILD_PREFIX}/share/gnuconfig/config.* .

autoreconf -if
./configure --prefix="${PREFIX}" \
	--disable-option-checking --enable-silent-rules --disable-dependency-tracking \
	--with-boost="${PREFIX}" \
	--with-boost-filesystem=yes \
	--with-boost-thread=yes \
	--with-boost-system=yes \
	--with-boost-iostreams=yes \
	--with-expat="${PREFIX}" \
	--with-zlib="${PREFIX}" \
	CC="${CC}" \
	CFLAGS="${CFLAGS}" \
	CXX="${CXX}" \
	CXXFLAGS="${CXXFLAGS}" \
	CPPFLAGS="${CPPFLAGS}" \
	LDFLAGS="${LDFLAGS}"

make
make install
