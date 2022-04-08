#!/bin/bash

mkdir -pv $PREFIX/bin
cp -rv clair3 models preprocess scripts  shared $PREFIX/bin
cp clair3.py $PREFIX/bin/
cp run_clair3.sh $PREFIX/bin/
make CC=${GCC} CXX=${GXX}  PREFIX=${PREFIX}
cp  longphase libclair3* $PREFIX/bin
