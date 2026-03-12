#!/bin/bash

set -euo pipefail

ARCH=$(uname -m)
OS=$(uname -s)
PYPY_VER="3.11-v7.3.20"

mkdir -pv $PREFIX/bin
cp -rv clair3 preprocess postprocess scripts shared $PREFIX/bin
cp clair3.py run_clair3.py $PREFIX/bin/
cp run_clair3.sh $PREFIX/bin/

if [ "$OS" = "Linux" ]; then
    if [ "$ARCH" = "x86_64" ]; then
        PYPY_DIR="${SRC_DIR}/pypy-linux64/pypy${PYPY_VER}-linux64"
    elif [ "$ARCH" = "aarch64" ]; then
        PYPY_DIR="${SRC_DIR}/pypy-aarch64/pypy${PYPY_VER}-aarch64"
    fi
    cp -rv ${PYPY_DIR} $PREFIX/bin/pypy3.11
    ln -s $PREFIX/bin/pypy3.11/bin/pypy $PREFIX/bin/pypy3
    ln -s $PREFIX/bin/pypy3.11/bin/pypy $PREFIX/bin/pypy
fi

$PREFIX/bin/pypy3 -m ensurepip
$PREFIX/bin/pypy3 -m pip install mpmath==1.2.1

pip install --no-deps --no-build-isolation .
make CC=${GCC} CXX=${GXX}  PREFIX=${PREFIX}
cp  longphase libclair3* $PREFIX/bin

mkdir -p $PREFIX/bin/models