#!/bin/bash

cd src
make CXX=${CXX} CXXFLAGS="${CXXFLAGS}" LDFLAGS="${LDFLAGS}" CFLAGS="${CFLAGS} -L${PREFIX}/lib -I${PREFIX}/include" CPPFLAGS="${CPPFLAGS} -L${PREFIX}/lib -I${PREFIX}/include-I. -O"
mkdir -p ${PREFIX}/bin
cp readItAndKeep ${PREFIX}/bin/
