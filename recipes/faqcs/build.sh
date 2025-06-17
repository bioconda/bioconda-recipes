#!/bin/bash

export CPLUS_INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

mkdir -p $PREFIX/bin
if [[ "$(uname -s)" == "Darwin" ]]; then
    echo "Installing FaQCs for OSX."
    make cc=$CC$ CC="${CLANGXX}" LIBS="-L${PREFIX}/lib -lm -lz" OPENMP=""
    cp FaQCs $PREFIX/bin
else 
    echo "Installing FaQCs for UNIX/Linux."
    make cc="${GCC}" CC="${CXX}" LIBS="-L${PREFIX}/lib -lm -lz"
    install -v -m 755 FaQCs $PREFIX/bin
fi
