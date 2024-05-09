#!/bin/bash -euo

BOOST_ROOT="${PREFIX}"
export DEST="${PREFIX}"
export PERL_EXT_CPPFLAGS="-D_REENTRANT -D_GNU_SOURCE -fwrapv -fno-strict-aliasing -pipe -fstack-protector"
export PERL_EXT_LDFLAGS="-shared -O2 -fstack-protector"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export LIBRARY_PATH="${PREFIX}/lib"
export INCLUDE_PATH="${PREFIX}/include"
export CFLAGS="-O3 -std=gnu90 ${LDFLAGS}"
export CXXFLAGS="-O3 -std=gnu++14 -I${PREFIX}/include ${LDFLAGS}"

cd global-1/

autoreconf -if

./configure --prefix="${DEST}" CC="${CC}" CFLAGS="${CFLAGS}" CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" \
	BOOST_ROOT="${PREFIX}" PERL_EXT_CPPFLAGS="${PERL_EXT_CPPFLAGS}" PERL_EXT_LDFLAGS="${PERL_EXT_LDFLAGS}"

cd ..

./install.sh
