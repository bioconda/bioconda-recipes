#!/bin/bash

mkdir -p $PREFIX/bin
make \ 
CXX="${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS}" \
CC="${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}" \
INCLUDE="-I$PREFIX/include"\ 
CFLAGS="-Wall -Wno-unused-variable -Wno-unused-function -Wno-misleading-indentation -I$PREFIX/include -L$PREFIX/lib -fopenmp"
install -d "${PREFIX}/bin"
install build/execs/xhmm "${PREFIX}/bin/"
