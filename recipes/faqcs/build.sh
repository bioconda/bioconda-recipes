#!/bin/bash

export CPLUS_INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

mkdir -p "${PREFIX}/bin"

sed -i.bak 's|gcc|$(CC)|' Makefile
sed -i.bak 's|g++|$(CXX)|' Makefile
sed -i.bak 's|-I.|-I. -I$(PREFIX)/include|' Makefile
if [[ "$(uname -m)" == "aarch64" || "$(uname -m)" == "arm64" ]]; then
    sed -i.bak 's|-msse2||' Makefile
fi
rm -rf *.bak

if [[ "$(uname -s)" == "Darwin" ]]; then
    echo "Installing FaQCs for OSX."
    make cc="${CC}" CC="${CXX}" LIBS="-L${PREFIX}/lib -lm -lz" OPENMP="" -j"${CPU_COUNT}"
    install -v -m 755 FaQCs "${PREFIX}/bin"
else
    echo "Installing FaQCs for UNIX/Linux."
    make cc="${CC}" CC="${CXX}" LIBS="-L${PREFIX}/lib -lm -lz" -j"${CPU_COUNT}"
    install -v -m 755 FaQCs "${PREFIX}/bin"
fi
