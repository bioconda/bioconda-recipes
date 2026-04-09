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
        PYPY_DIR="${SRC_DIR}/pypy-linux64"
    elif [ "$ARCH" = "aarch64" ]; then
        PYPY_DIR="${SRC_DIR}/pypy-aarch64"
    fi
    cp -rv ${PYPY_DIR} $PREFIX/bin/pypy3.11
    ln -s $PREFIX/bin/pypy3.11/bin/pypy $PREFIX/bin/pypy3
    ln -s $PREFIX/bin/pypy3.11/bin/pypy $PREFIX/bin/pypy

    $PREFIX/bin/pypy3 -m ensurepip
    MPMATH_SRC=$(python -c "import mpmath, os; print(os.path.dirname(mpmath.__file__))")
    PYPY_SITE=$(${PREFIX}/bin/pypy3 -c "import site; print(site.getsitepackages()[0])")
    cp -r ${MPMATH_SRC} ${PYPY_SITE}/
elif [ "$OS" = "Darwin" ] && [ "$ARCH" = "arm64" ]; then
    PYPY_DIR="${SRC_DIR}/pypy-macos-arm64"
    cp -rv ${PYPY_DIR} $PREFIX/bin/pypy3.11
    ln -s $PREFIX/bin/pypy3.11/bin/pypy $PREFIX/bin/pypy3
    ln -s $PREFIX/bin/pypy3.11/bin/pypy $PREFIX/bin/pypy

    $PREFIX/bin/pypy3 -m ensurepip
    MPMATH_SRC=$(python -c "import mpmath, os; print(os.path.dirname(mpmath.__file__))")
    PYPY_SITE=$(${PREFIX}/bin/pypy3 -c "import site; print(site.getsitepackages()[0])")
    cp -r ${MPMATH_SRC} ${PYPY_SITE}/
fi


cd ${SRC_DIR}

export LDFLAGS="${LDFLAGS} -ldeflate"
make CC=${CC} CXX=${CXX} PREFIX=${PREFIX} CC_PATH=${CC}
cp libclair3*.so $PREFIX/bin
if [ "$OS" = "Linux" ]; then
    cp longphase $PREFIX/bin
fi

mkdir -p $PREFIX/bin/models

