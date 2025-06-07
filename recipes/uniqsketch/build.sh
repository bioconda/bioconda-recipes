#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"

mkdir -p "${PREFIX}/bin"

sed -i.bak 's|g++|$(CXX)|' Makefile
sed -i.bak 's|-Iinclude|-Iinclude -I$(PREFIX)/include|' Makefile
rm -rf *.bak

make CXX="${CXX}" -j"${CPU_COUNT}"

install -v -m 0755 bin/* "${PREFIX}/bin"
