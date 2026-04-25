#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3 -Wno-implicit-function-declaration"

install -d "${PREFIX}/bin"

cd src

make CC="${CC}" -j"${CPU_COUNT}"

install -v -m 0755 minion \
    reaper \
    swan \
    tally \
    "${PREFIX}/bin"
