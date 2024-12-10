#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export CPATH="${PREFIX}/include"

mkdir -pv $PREFIX/bin
cp -rf clair3 models preprocess postprocess scripts shared $PREFIX/bin
install -v -m 0755 clair3.py $PREFIX/bin/
install -v -m 0755 run_clair3.sh $PREFIX/bin/
make all GCC="${CC}" GXX="${CXX}" PREFIX="${PREFIX}" LDFLAGS="${LDFLAGS}"

install -v -m 0755 longphase $PREFIX/bin
cp -rf libclair3* $PREFIX/bin
