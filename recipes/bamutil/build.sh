#!/usr/bin/env bash

cd bamUtil
make \
    CXX="${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS} -std=c++11 -fpermissive" \
    CC="${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS} -std=c++11 -fpermissive" \
    USER_WARNINGS='-Wno-strict-overflow' \
    INSTALLDIR="${PREFIX}/bin/" \
    install
