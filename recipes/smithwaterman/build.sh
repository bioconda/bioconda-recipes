#!/bin/bash
set -ex

mkdir -p ${PREFIX}/bin

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3 -I${PREFIX}/include"

sed -i.bak 's|c++|$(CXX)|' Makefile
sed -i.bak 's|CFLAGS|CXXFLAGS|' Makefile
rm -rf *.bak

if [[ `uname -s` == "Darwin" ]]; then
	sed -i.bak 's|-Wl,-s|-Wl|' Makefile
	rm -rf *.bak
fi

make CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" -j"${CPU_COUNT}"

install -v -m 0755 smithwaterman "${PREFIX}/bin"
