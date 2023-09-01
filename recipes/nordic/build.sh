#!/usr/bin/env bash

cd MaBoSS-2.0/src
make install \
    CC="${CC}" \
    CXX="${CXX}" \
    CFLAGS="${CFLAGS}" \
    CXXFLAGS="${CXXFLAGS}" \
    LDFLAGS="${LDFLAGS}" \
    prefix="${PREFIX}"
"${PYTHON}" -m pip install bonesis maboss mpbn
"${PYTHON}" -m pip install --no-deps --ignore-installed . -vv