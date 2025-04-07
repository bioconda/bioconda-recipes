#!/bin/bash

export CFLAGS="${CFLAGS} -O3 -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

if [[ "$(uname)" == "Darwin" ]]; then
    export LDFLAGS="${LDFLAGS} -lomp"
else
    export CFLAGS="${CFLAGS} -fopenmp"
fi 

make -j"${CPU_COUNT}"
make install PREFIX="${PREFIX}"
