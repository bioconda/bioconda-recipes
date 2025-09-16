#!/bin/sh

set -xe

if [ "$(uname)" == "Darwin" ]; then
    DEP_LIBS="${LDFLAGS}" make -j ${CPU_COUNT} CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" -f Makefile.osx bin
else
    DEP_LIBS="${LDFLAGS}" make -j ${CPU_COUNT} CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" -f Makefile.c++11 bin
fi

mkdir -p "${PREFIX}/bin"
cp bin/dsrc "${PREFIX}/bin/"
