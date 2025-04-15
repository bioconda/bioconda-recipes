#!/usr/bin/env bash

set -x -e
BOOST_ROOT="${PREFIX}"
export DEST="${PREFIX}"
export PERL_EXT_CPPFLAGS="-D_REENTRANT -D_GNU_SOURCE -fwrapv -fno-strict-aliasing -pipe -fstack-protector"
export PERL_EXT_LDFLAGS="-shared -O3 -fstack-protector"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export LIBRARY_PATH="${PREFIX}/lib"
export INCLUDE_PATH="${PREFIX}/include"
export CPATH="${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3 -std=gnu90 ${LDFLAGS}"
export CXXFLAGS="${CXXFLAGS} -O3 -std=c++14 -I${PREFIX}/include ${LDFLAGS}"
./install.sh
