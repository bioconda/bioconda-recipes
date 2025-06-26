#!/bin/bash

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

install -d "${PREFIX}/bin"

cd src

sed -i.bak 's|g++|$(CXX)|' makefile
sed -i.bak 's|LDFLAGS=|LDFLAGS=-L$(PREFIX)/lib|' makefile
rm -rf *.bak

make CXX="${CXX}" -j"${CPU_COUNT}"

install -v -m 0755 FamSeq "${PREFIX}/bin"
