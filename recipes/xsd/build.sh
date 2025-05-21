#!/bin/bash

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

make CC="${CC}" CXX="${CXX}" AR="${AR} rcs" RANLIB="${RANLIB}" CPPFLAGS="${CPPFLAGS}" CXXFLAGS="${CXXFLAGS} -O3 -std=c++14" LDFLAGS="${LDFLAGS}" -j"${CPU_COUNT}"
make install_prefix="${PREFIX}" install
