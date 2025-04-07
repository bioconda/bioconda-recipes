#!/bin/bash

export CFLAGS="${CFLAGS} -O3 -I$PREFIX/include"
export LDFLAGS="${LDFLAGS} -L$PREFIX/lib"

if [[ "$(uname)" == "Darwin" ]]; then
    version=`conda info llvm-openmp | grep '^version' | awk -F': ' '{print $2}'`
    CFLAGS="-I${PREFIX}/lib/clang/${version}/include ${CFLAGS}"
    LDFLAGS="-lomp ${LDFLAGS}"
else
    CFLAGS="-fopenmp ${CFLAGS}"
fi 

make -j"${CPU_COUNT}"
make install PREFIX="${PREFIX}"
