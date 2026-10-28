#!/bin/bash
set -eu

mkdir -p "${PREFIX}/bin"
chmod a+x bin/*
cp bin/* "${PREFIX}/bin/"

mkdir -p "${PREFIX}/data"
chmod -R a+rX data/*
cp -r data/* "${PREFIX}/data/"

LIBSVM_DIR="${PREFIX}/libs/libsvm/libsvm-3.18"
mkdir -p "${LIBSVM_DIR}"
ln -sf "${PREFIX}/bin/svm-scale"   "${LIBSVM_DIR}/svm-scale"
ln -sf "${PREFIX}/bin/svm-predict" "${LIBSVM_DIR}/svm-predict"