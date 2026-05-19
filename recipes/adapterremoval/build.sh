#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"

sed -i.bak -e 's/install -d/mkdir -p/' Makefile
rm -f *.bak

make
make install PREFIX="${PREFIX}"
