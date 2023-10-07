#!/usr/bin/env bash

cd ${SRC_DIR}"/MaBoSS-2.0/"
FILE=$(ls | grep "master*.tar.gz")
unzip $FILE
cd MaBoSS-env-2.0-master/engine/src
make install \
    CC="${CC}" \
    CXX="${CXX}" \
    CFLAGS="${CFLAGS}" \
    CXXFLAGS="${CXXFLAGS}" \
    LDFLAGS="${LDFLAGS}" \
    prefix="${PREFIX}"
"${PYTHON}" -m pip install bonesis maboss mpbn
"${PYTHON}" -m pip install --no-deps --no-build-isolation . -vvv