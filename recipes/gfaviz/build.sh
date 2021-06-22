#!/bin/bash
export CFLAGS="$CFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
export CPATH=${PREFIX}/include

mkdir -p $PREFIX/bin

qmake CC="${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}"  CXX="${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS}"
make CC="${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}"  CXX="${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS}"
cp gfaviz $PREFIX/bin

