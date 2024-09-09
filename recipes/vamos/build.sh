#!/bin/bash

set -xe

mkdir -p $PREFIX/bin
export CFLAGS="$CFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
export CPATH=${PREFIX}/include

cd src && make -j ${CPU_COUNT} CC="${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS} -fPIE "  CXX="${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS} -fPIE" && cd ..

cp src/vamos $PREFIX/bin

