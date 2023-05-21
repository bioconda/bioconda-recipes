#!/bin/bash
OPTFLAG_PROFILE="-O3" \
    make install \
    INSTALLDIR="${PREFIX}/bin/" \
    CXX="${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS} -std=c++11" \
    CC="${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}" \
    USER_WARNINGS='-Wno-strict-overflow'
