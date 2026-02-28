#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"

install -d "${PREFIX}/bin"

cd nano_src

make CC="${CXX} ${CXXFLAGS} ${CPPFLAGS}" -j"${CPU_COUNT}"

install -v -m 0755 nanoblaster "${PREFIX}/bin"
