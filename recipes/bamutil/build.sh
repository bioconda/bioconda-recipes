#!/usr/bin/env bash

set -xe

cd bamUtil
make -j ${CPU_COUNT} \
    CXX="${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS} -std=c++11" \
    CC="${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}" \
    USER_WARNINGS='-Wno-strict-overflow' \
    INSTALLDIR="${PREFIX}/bin/" \
    install
