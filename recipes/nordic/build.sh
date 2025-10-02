#!/usr/bin/env bash

set -xe

#cd ${SRC_DIR}"/MaBoSS-2.0/engine/src/"

#make -j"${CPU_COUNT}" install \
#    CC="${CC}" \
#    CXX="${CXX}" \
#    CFLAGS="${CFLAGS}" \
#    CXXFLAGS="${CXXFLAGS}" \
#    LDFLAGS="${LDFLAGS}" \
#    prefix="${PREFIX}"

conda install -c colomoto -y -q maboss

cd ${SRC_DIR}"/mpbn-4.2/"

"${PYTHON}" -m pip install --no-deps --no-build-isolation . -vvv

cd ${SRC_DIR}"/bonesis-0.6.8.1/"

"${PYTHON}" -m pip install --no-deps --no-build-isolation . -vvv

cd ${SRC_DIR}"/NORDic-2.7.1/" || exit 1

"${PYTHON}" -m pip install --no-deps --no-build-isolation . -vvv
