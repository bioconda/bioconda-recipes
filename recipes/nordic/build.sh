#!/usr/bin/env bash

wget https://github.com/sysbio-curie/MaBoSS-env-2.0/archive/refs/heads/master.tar.gz
tar xvfz MaBoSS-2.0.tar.gz
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