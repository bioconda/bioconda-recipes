#!/bin/bash

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"

./configure --prefix="${PREFIX}" CXX="${CXX}" CXXFLAGS="${CXXFLAGS} -std=c++14" CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include -std=c++14" LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
make
make install
