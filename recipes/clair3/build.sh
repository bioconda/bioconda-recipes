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

if [ "$OS" = "Darwin" ]; then
    LDFLAGS="${LDFLAGS//-Wl,-rpath=/-Wl,-rpath,}"
    export LDFLAGS
fi

make libhts.a libclair3.so CC=${CC} CXX=${CXX} PREFIX=${PREFIX} CC_PATH=${CC}
cp libclair3*.so $PREFIX/bin

# ---- Bundle pre-trained models -------------------------------------------
# All Clair3 models are pre-packaged into a single archive so the build only
# needs ONE download instead of many small per-file requests. It unpacks to
# ${PREFIX}/bin/models/<model>/{pileup.pt,full_alignment.pt}.
# Override CLAIR3_MODELS_URL to use a mirror, or set it to "" to skip bundling.
# Individual / additional models can be downloaded by users from:
#   https://www.bio8.cs.hku.hk/clair3/clair3_models_pytorch/
#   https://www.bio8.cs.hku.hk/clair3/clair3_models_rerio_pytorch/
CLAIR3_MODELS_URL="${CLAIR3_MODELS_URL-https://www.bio8.cs.hku.hk/clair3/bioconda/clair3_models_v2.0.2.tar.gz}"
CLAIR3_MODELS_SHA256="${CLAIR3_MODELS_SHA256-27c7ea0777134567861e1f305a368d89a199332a1118a4f70df8bfebdbe1306b}"

mkdir -p "$PREFIX/bin/models"
if [ -n "$CLAIR3_MODELS_URL" ]; then
    echo "Downloading bundled Clair3 models from ${CLAIR3_MODELS_URL}"
    curl -fSL -o clair3_models.tar.gz "$CLAIR3_MODELS_URL"
    if [ -n "$CLAIR3_MODELS_SHA256" ]; then
        actual=$( { sha256sum clair3_models.tar.gz 2>/dev/null || shasum -a 256 clair3_models.tar.gz; } | awk '{print $1}' )
        if [ "$actual" != "$CLAIR3_MODELS_SHA256" ]; then
            echo "ERROR: model archive sha256 mismatch (expected ${CLAIR3_MODELS_SHA256}, got ${actual})" >&2
            exit 1
        fi
    fi
    tar xzf clair3_models.tar.gz -C "$PREFIX/bin/"
    rm -f clair3_models.tar.gz
fi

