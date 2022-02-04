#!/bin/bash

export CFLAGS="$CFLAGS -I$PREFIX/include -DVERSION=1.2.3"
export CXXFLAGS="$CXXFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib -lz"

mkdir build
cd build
cmake ..
make \
    CXX="${CXX} ${CXXFLAGS} ${LDFLAGS}" \
    CC="${CC} ${CFLAGS} ${LDFLAGS}"

cp -v chips ${PREFIX}/bin/chips
