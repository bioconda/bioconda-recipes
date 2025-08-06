#!/bin/bash
set -ex

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib -Wl,-rpath,${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3 -Wno-deprecated-declarations"

autoreconf -if
./configure --prefix="${PREFIX}" \
	CC="${CC}" \
	CFLAGS="${CFLAGS}" \
	CPPFLAGS="${CPPFLAGS}" \
	LDFLAGS="${LDFLAGS}" \
	--disable-option-checking --enable-silent-rules --disable-dependency-tracking

ln -sf gadem_documentation_v1.3.1.pdf doc/GADEM_documentation.pdf

make -j1
make install
