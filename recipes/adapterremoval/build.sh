#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3 -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=2"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3 -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=2"

sed -i.bak -e 's/install -d/mkdir -p/' Makefile
rm -f *.bak

make

make install PREFIX="${PREFIX}"
