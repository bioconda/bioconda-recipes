#!/usr/bin/env bash

cd bamUtil
make \
    CXX="${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS} -std=c++11" \
    CC="${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}" \
    USER_WARNINGS='-Wno-strict-overflow' \
    INSTALLDIR="${PREFIX}/bin/" \
    install
