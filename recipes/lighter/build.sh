#!/bin/bash

mkdir -p ${PREFIX}/bin

make CXX="${CXX}" CXXFLAGS="${CXXFLAGS} -O3 -I${PREFIX}/include" LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

chmod 0755 lighter
cp -f lighter ${PREFIX}/bin
