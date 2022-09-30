#!/bin/sh

make all CXX="${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS} -std=c++03"
make install

mkdir -p $PREFIX/bin
ls
cp bin/* $PREFIX/bin/
