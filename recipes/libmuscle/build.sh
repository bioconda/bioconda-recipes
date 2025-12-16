#!/bin/bash

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3 -Wno-deprecated-declarations"
export CXXFLAGS="${CXXFLAGS} -O3"

sed -i.bak ' s| = muscle| = |g' libMUSCLE/Makefile.am

./autogen.sh
./configure --prefix="${PREFIX}" \
	--disable-option-checking --enable-silent-rules \
	--enable-dependency-tracking CC="${CC}" \
	CXX="${CXX}" CFLAGS="${CFLAGS}" \
	CXXFLAGS="${CXXFLAGS}" CPPFLAGS="${CPPFLAGS}" \
	LDFLAGS="${LDFLAGS}"

make -j"${CPU_COUNT}"
make install
