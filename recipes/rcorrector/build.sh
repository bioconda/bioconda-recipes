#!/bin/bash

export CPLUS_INCLUDE_PATH="$PREFIX/include"
export CFLAGS="${CFLAGS} -O3 -I$PREFIX/include"
export CXXFLAGS="${CXXFLAGS} -Wall -O3 -std=c++0x"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"

mkdir -p "$PREFIX/bin"

sed -i.bak 's/CXXFLAGS=.*//' Makefile
sed -i.bak '/char nucToNum/s/^/signed\ /g' main.cpp
sed -i.bak '/char numToNuc/s/^/signed\ /g' main.cpp
rm -rf *.bak

make CXX="${CXX}" -j"${CPU_COUNT}"
install -v -m 755 rcorrector run_rcorrector.pl "$PREFIX/bin"
