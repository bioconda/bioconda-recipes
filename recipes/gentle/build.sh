#!/bin/bash
set -ex
autoreconf -if

./configure --prefix="${PREFIX}" CXX="${CXX}" CXXFLAGS="${CXXFLAGS} -O3 -I${PREFIX}/include" LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
make
make install
