#!/bin/bash
set -eu -o pipefail

mkdir -p ${PREFIX}/bin

export CXXFLAGS="${CXXFLAGS} -O3 -Wno-narrowing"

sed -i.bak 's|-lpthread|-pthread|' Makefile
sed -i.bak 's|-std=c++11|-std=c++14|' Makefile
rm -rf *.bak

if [[ $OSTYPE == "darwin"* ]]; then
  LDFLAGS="${LDFLAGS} -L${PREFIX}/lib -lc"
fi

make DIR_INC="${PREFIX}/include" LIBRARY_DIRS="${PREFIX}/lib" CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" -j"${CPU_COUNT}"
make install BINDIR="${PREFIX}/bin"
