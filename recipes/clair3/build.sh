#!/bin/bash

mkdir -pv $PREFIX/bin
cp -rf clair3 models preprocess postprocess scripts shared $PREFIX/bin
install -v -m 0755 clair3.py $PREFIX/bin/
install -v -m 0755 run_clair3.sh $PREFIX/bin/
make CC="${CC}" CXX="${CXX}" PREFIX="${PREFIX}" -j"${CPU_COUNT}"

install -v -m 0755 longphase $PREFIX/bin
cp -rf libclair3* $PREFIX/bin
