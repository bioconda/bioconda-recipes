#!/bin/bash

set -xe

mkdir -p $PREFIX/bin

export CXXFLAGS="${CXXFLAGS} -O3 -D_LIBCPP_DISABLE_AVAILABILITY -mmacosx-version-min=10.15 -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
export CPATH="${PREFIX}/include"
export EIGEN_ROOT="${PREFIX}"

cd src
make -j "${CPU_COUNT}" CC="${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS} -fPIE" CXX="${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS} -fPIE"
cd ..

install -v -m 0755 src/ctyper "${PREFIX}/bin"
