#!/bin/bash

cd src
make CXX=${CXX} CXX_FLAGS="${CXXFLAGS} -I${PREFIX}/include -L${PREFIX}/lib" CXXFLAGS="${CXXFLAGS} -I${PREFIX}/include -L${PREFIX}/lib" LDFLAGS="${LDFLAGS}" CFLAGS="${CFLAGS} -L${PREFIX}/lib -I${PREFIX}/include" CPPFLAGS="${CPPFLAGS} -L${PREFIX}/lib -I${PREFIX}/include -I. -O"
mkdir -p ${PREFIX}/bin
cp readItAndKeep ${PREFIX}/bin/
