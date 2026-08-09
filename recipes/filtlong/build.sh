#!/bin/bash
set -xe 

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3"

install -d "${PREFIX}/bin"

make CXXFLAGS="${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS}" -j"${CPU_COUNT}"

install -v -m 0755 bin/filtlong "${PREFIX}/bin"
