#!/bin/sh

if [ "$(uname)" == "Darwin" ]; then
    make CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" -f Makefile.osx bin
else
    make CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" bin
fi

cp bin/dsrc $PREFIX/bin
