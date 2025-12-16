#!/bin/bash

ARCH=$(uname -m)

mkdir -pv $PREFIX/bin
cp -rv clair3 models preprocess postprocess scripts shared $PREFIX/bin
cp clair3.py $PREFIX/bin/
cp run_clair3.sh $PREFIX/bin/
if [ "$ARCH" = "x86_64" ]; then
    cp -rv pypy3.10-v7.3.19-linux64 $PREFIX/bin
    cp -P pypy3 pypy $PREFIX/bin
elif [ "$ARCH" = "aarch64" ]; then
    cp -rv pypy3.10-v7.3.19-aarch64 $PREFIX/bin
    cp -P pypy3-aarch64 $PREFIX/bin/pypy3
    cp -P pypy-aarch64 $PREFIX/bin/pypy
else
    cp -rv pypy3.10-v7.3.19-linux64 $PREFIX/bin
    cp -P pypy3 pypy $PREFIX/bin
fi
make CC=${GCC} CXX=${GXX}  PREFIX=${PREFIX}
cp  longphase libclair3* $PREFIX/bin
