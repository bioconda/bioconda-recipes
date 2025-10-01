#!/bin/bash
set -ex

export CPPFLAGS="${CPPFLAGS} -I$PREFIX/include"
export LDFLAGS="${LDFLAGS} -L$PREFIX/lib"
export CXXFLAGS="${CXXFLAGS} -O3"

autoreconf -if
./configure --prefix="${PREFIX}" --disable-option-checking --enable-silent-rules \
    --disable-dependency-tracking CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" \
    CPPFLAGS="${CPPFLAGS}" LDFLAGS="${LDFLAGS}"

make -j"${CPU_COUNT}"
make install
