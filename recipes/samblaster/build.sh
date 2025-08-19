#!/bin/bash

mkdir -p "$PREFIX/bin"

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"

sed -i.bak 's/CPPFLAGS = /CPPFLAGS = $(CXXFLAGS) /' Makefile
rm -rf *.bak

make CPP="${CXX}" -j"${CPU_COUNT}"

install -v -m 0755 samblaster "$PREFIX/bin"
