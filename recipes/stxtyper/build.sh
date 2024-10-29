#!/bin/bash

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3"
export CPPFLAGS="${CPPFLAGS} -O3 -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

make CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" CPPFLAGS="${CPPFLAGS}" -j"${CPU_COUNT}"

make install PREFIX="${PREFIX}"
