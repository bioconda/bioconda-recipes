#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"

mkdir -p $PREFIX/bin

${CXX} -I$PREFIX/include/bamtools -I./ -L$PREFIX/lib -O3 -o ngs_disambiguate dismain.cpp -lz -lbamtools

install -v -m 0755 ngs_disambiguate "$PREFIX/bin"
