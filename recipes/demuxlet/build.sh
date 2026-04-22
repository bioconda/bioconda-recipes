#!/bin/bash
set -x -e

export INCLUDE_PATH="${PREFIX}/include:${PREFIX}/include/htslib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include -Wno-sign-compare -Wno-format"
export CFLAGS="${CFLAGS} -O3 -I${PREFIX}/include -I${PREFIX}/include/htslib -ldl -ldeflate -fno-strict-aliasing"
export CXXFLAGS="${CXXFLAGS} -O3 -I${PREFIX}/htslib -ldl -ldeflate"
export LC_ALL="en_US.UTF-8"

mkdir -p m4
cp -rf ${BUILD_PREFIX}/share/gnuconfig/config.* m4/

if [[ "$(uname -s)" == "Darwin" ]]; then
	sed -i.bak 's|-lgomp|-lomp|' Makefile.am
	rm -rf *.bak
fi

autoreconf -if
./configure --prefix="${PREFIX}" \
	CC="${CC}" CFLAGS="${CFLAGS}" \
	CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" \
	CPPFLAGS="${CPPFLAGS}" LDFLAGS="${LDFLAGS}" \
	--disable-option-checking --enable-silent-rules --disable-dependency-tracking

make -j"${CPU_COUNT}"
make install
