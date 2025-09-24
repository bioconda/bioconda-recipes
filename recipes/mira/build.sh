#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I$PREFIX/include"
export CFLAGS="${CFLAGS} -O3"
export CXXFLAGS="${CXXFLAGS} -O3 -std=c++14"

mkdir -p "${PREFIX}/bin"

cp -f ${BUILD_PREFIX}/share/gnuconfig/config.* .

autoreconf -if
./configure --prefix="${PREFIX}" \
	--disable-option-checking --enable-silent-rules --disable-dependency-tracking \
	--with-boost="${PREFIX}" \
	--with-boost-libdir="${PREFIX}/lib" \
	--with-expat="${PREFIX}" \
	--with-zlib="${PREFIX}" \
	CC="${CC}" \
	CFLAGS="${CFLAGS}" \
	CXX="${CXX}" \
	CXXFLAGS="${CXXFLAGS}" \
	CPPFLAGS="${CPPFLAGS}" \
	LDFLAGS="${LDFLAGS}" \
	LIBS="-lz -lbz2 -lboost_filesystem -lboost_thread -lboost_system -lboost_iostreams"

make
make install
