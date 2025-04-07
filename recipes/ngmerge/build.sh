#!/bin/bash

export CFLAGS="${CFLAGS} -g -Wall -std=gnu99 -O3 -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

if [[ "$(uname)" == "Darwin" ]]; then
    export LDFLAGS="${LDFLAGS} -lomp"
else
    export CFLAGS="${CFLAGS} -fopenmp"
fi 

make CC="${CC}" CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" -j"${CPU_COUNT}"
make install PREFIX="${PREFIX}"
