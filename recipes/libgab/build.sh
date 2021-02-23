#!/bin/bash

export CFLAGS="$CFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"

mkdir -p ${PREFIX}/include/libgab/
mkdir -p ${PREFIX}/lib/libgab/
mkdir -p ${PREFIX}/include/libgab/gzstream/
mkdir -p ${PREFIX}/lib/libgab/gzstream/

make  CXX="${CXX}"   all
cp libgab*a ${PREFIX}/lib/libgab/
cp     *\.h ${PREFIX}/include/libgab/
cp     gzstream/*\.h          ${PREFIX}/include/libgab/gzstream/
cp     gzstream/libgzstream.a ${PREFIX}/include/libgab/gzstream/
cd ..

