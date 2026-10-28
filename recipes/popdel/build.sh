#!/bin/bash

mkdir -p "${PREFIX}/bin"

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"

make CXX="${CXX}" -j"${CPU_COUNT}"

install -v -m 0755 popdel "${PREFIX}/bin"
