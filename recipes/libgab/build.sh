#!/bin/bash

export CFLAGS="$CFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"

mkdir -p ${PREFIX}/include/libgab/
mkdir -p ${PREFIX}/lib/libgab/

make  CXX="${CXX}"   all
cp libgab*a ${PREFIX}/lib/libgab/
cp     *\.h ${PREFIX}/include/libgab/
cd ..

