#!/usr/bin/env bash

cd ${SRC_DIR}"/MaBoSS-2.0/engine/src/"

make install \
    CC="${CC}" \
    CXX="${CXX}" \
    CFLAGS="${CFLAGS}" \
    CXXFLAGS="${CXXFLAGS}" \
    LDFLAGS="${LDFLAGS}" \
    prefix="${PREFIX}"

"${CONDA}" install -c colomoto bonesis
"${CONDA}" install -c colomoto mpbn
"${PYTHON}" -m pip install --no-deps --no-build-isolation . -vvv