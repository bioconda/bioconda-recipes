#!/bin/bash

export CFLAGS="${CFLAGS} -O3 -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

if [[ "$(uname)" == "Darwin" ]]; then
    export CFLAGS="-I${PREFIX}/lib/clang/${version}/include ${CFLAGS}"
    export LDFLAGS="-lomp ${LDFLAGS}"
else
    export CFLAGS="-fopenmp ${CFLAGS}"
fi 

make -j"${CPU_COUNT}"
make install PREFIX="${PREFIX}"
