#!/bin/bash

export CFLAGS="${CFLAGS} -g -Wall -std=gnu11 -O3 -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

if [[ "$(uname)" == "Darwin" ]]; then
    export LDFLAGS="${LDFLAGS} -lomp"
else
    export CFLAGS="${CFLAGS} -fopenmp"
fi 

make CC="${CC}" CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" -j"${CPU_COUNT}"
install -v -m 0755 NGmerge "${PREFIX}/bin"
