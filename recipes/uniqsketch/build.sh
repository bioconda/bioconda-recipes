#!/bin/bash

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib -fopenmp"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"

mkdir -p "${PREFIX}/bin"

sed -i.bak 's|g++|$(CXX)|' Makefile
sed -i.bak 's|-Ivendor|-Ivendor -I$(PREFIX)/include|' Makefile
sed -i.bak 's|-lz|-L$(PREFIX)/lib -lz|' Makefile
rm -rf *.bak

make CXX="${CXX}" -j"${CPU_COUNT}"

install -v -m 0755 bin/* "${PREFIX}/bin"
