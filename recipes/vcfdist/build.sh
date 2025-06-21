#!/bin/bash

export CPATH="${PREFIX}/include"
export CPLUS_INCLUDE_PATH="${PREFIX}/include"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

sed -i.bak 's|-lpthread|-pthread|' Makefile
sed -i.bak 's|g++|$(CXX)|' Makefile

cd src && make CXX="${CXX}" -j"${CPU_COUNT}"
install -d "${PREFIX}/bin"
install -v -m 755 vcfdist "${PREFIX}/bin"
