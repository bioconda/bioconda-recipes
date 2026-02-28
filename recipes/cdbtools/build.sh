#!/bin/bash

mkdir -pv "${PREFIX}/bin"

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"

make CC="${CXX}" LINKER="${CXX}" -j"${CPU_COUNT}"
install -v -m 0755 cdbfasta "${PREFIX}/bin"
install -v -m 0755 cdbyank "${PREFIX}/bin"
