#!/bin/bash
set -eu

autoreconf -if
./configure --prefix="${PREFIX}" CXX="${CXX}" \
	--with-libmaus2 --with-xerces-c --with-gmp \
	CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include" \
	LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
make install
