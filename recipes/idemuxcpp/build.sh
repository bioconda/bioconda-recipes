#!/bin/sh

export CXXFLAGS="-I${PREFIX}/include/bamtools ${CXXFLAGS}"
export LDFLAGS="-L${PREFIX}/lib/ -lbamtools ${LDFLAGS}"
./configure --enable-tests --prefix="${PREFIX}"
make
make install
make check
