#!/bin/bash

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
if [[ "$(uname)" == Darwin ]]; then
    version=`conda info llvm-openmp | grep '^version' | awk -F': ' '{print $2}'`
    CFLAGS="-I${PREFIX}/lib/clang/${version}/include ${CFLAGS}"
    LDFLAGS="-lomp $LDFLAGS"
else
    CFLAGS="-fopenmp $CFLAGS"
fi 

make
make install PREFIX=$PREFIX
