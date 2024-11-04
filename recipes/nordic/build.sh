#!/usr/bin/env bash

cd ${SRC_DIR}"/MaBoSS-2.0/engine/src/"

make install \
    CC="${CC}" \
    CXX="${CXX}" \
    CFLAGS="${CFLAGS}" \
    CXXFLAGS="${CXXFLAGS}" \
    LDFLAGS="${LDFLAGS}" \
    prefix="${PREFIX}"

cd ${SRC_DIR}"/mpbn-3.3/"

"${PYTHON}" -m pip install --no-deps --no-build-isolation . -vvv

cd ${SRC_DIR}"/bonesis-0.5.7/"

"${PYTHON}" -m pip install --no-deps --no-build-isolation . -vvv

cd ${SRC_DIR}"/NORDic-2.5.0/"

"${PYTHON}" -m pip install --no-deps --no-build-isolation . -vvv
