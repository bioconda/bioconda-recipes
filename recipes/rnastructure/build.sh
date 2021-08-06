#!/bin/sh

# Fix for OSX build
if [ `uname` == Darwin ]; then
	CXXFLAGS="${CXXFLAGS} -g -O3 -fopenmp -I${PREFIX}/include"
else
	CXXFLAGS="${CXXFLAGS} -fopenmp -g -O3"
fi

# build
make CC="${CC}" CXX="${CXX}" all

mkdir -p $PREFIX/bin
mv ./exe/* $PREFIX/bin/

# Some of the tools inside the package require the information in /data_tables
# This makes them accessible from a relative path to the binaries.

mkdir -p $PREFIX/share/${PKG_NAME}/data_tables
mv ./data_tables/* $PREFIX/share/${PKG_NAME}/data_tables/
