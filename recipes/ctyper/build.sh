#!/bin/bash

set -xe

mkdir -p $PREFIX/bin

export CXXFLAGS="${CXXFLAGS} -O3 -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
export CPATH="${PREFIX}/include"
export EIGEN_ROOT="${PREFIX}"

if [[ "$(uname)" == "Darwin" ]]; then
  export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY -mmacosx-version-min=10.15"
fi

cd src
make -j"${CPU_COUNT}" CC="${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS} -fPIE" CXX="${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS} -fPIE"
cd ..

install -v -m 0755 src/ctyper "${PREFIX}/bin"
