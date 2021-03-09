#!/bin/bash

mkdir -p $PREFIX/bin

cd src
autoreconf -fi

./configure --prefix=$PREFIX
make CC="${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}"  CXX="${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS}" PREFIX=$PREFIX
make install PREFIX=$PREFIX
