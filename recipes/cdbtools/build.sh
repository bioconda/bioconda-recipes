#!/bin/bash

mkdir -pv ${PREFIX}/bin

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3 -Wno-register"

if [[ `uname` == "Darwin" ]]; then
  export CXXFLAGS="${CXXFLAGS} -Wno-unused-but-set-variable -Wno-misleading-indentation"
fi

make CC="${CXX}" LINKER="${CXX}" -j"${CPU_COUNT}"
install -v -m 0755 cdbfasta "${PREFIX}/bin"
install -v -m 0755 cdbyank "${PREFIX}/bin"
