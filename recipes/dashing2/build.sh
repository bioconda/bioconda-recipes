#!/bin/bash

mkdir -p "${PREFIX}/bin"

export CPLUS_INCLUDE_PATH="${PREFIX}/include"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

make CC="${CC}" CXX="${CXX}" -j"${CPU_COUNT}"

install -v -m 0755 dashing2 dashing2-64 dashing2-tmp "${PREFIX}/bin"
