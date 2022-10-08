#!/bin/sh

# Fix for OSX build
if [ `uname` == Darwin ]; then
    CPP_FLAGS="${CXXFLAGS} -g -O3 -fopenmp -I${PREFIX}/include"
    sed -i.bak "s/gomp/omp/g" compiler.h
else
    CPP_FLAGS="${CXXFLAGS} -fopenmp -g -O3"
fi

# build
make CC="${CC}" CXX="${CXX}" CPP_FLAGS="${CPP_FLAGS}" all

mkdir -p $PREFIX/bin
mv ./exe/* $PREFIX/bin/

# Some of the tools inside the package require the information in /data_tables
# This makes them accessible from a relative path to the binaries.

mkdir -p $PREFIX/share/${PKG_NAME}/data_tables
mv ./data_tables/* $PREFIX/share/${PKG_NAME}/data_tables/
