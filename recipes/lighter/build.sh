#!/bin/bash

mkdir -p ${PREFIX}/bin

make CXX="${CXX}" CXXFLAGS="${CXXFLAGS} -O3 -I${PREFIX}/include" LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

cp -f lighter ${PREFIX}/bin
