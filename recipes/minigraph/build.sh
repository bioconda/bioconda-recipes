#!/bin/bash

mkdir -p $PREFIX/bin

export CPATH=${PREFIX}/include

make  CC="${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}"  CXX="${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS}"
cp minigraph $PREFIX/bin
