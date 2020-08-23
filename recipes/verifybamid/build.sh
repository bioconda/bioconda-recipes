#!/bin/bash
OPTFLAG_PROFILE="-O3" \
    make install \
    INSTALLDIR="${PREFIX}/bin/" \
    CXX="${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS} -std=c++11 -fpermissive" \
    CC="${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS} -std=c++11 -fpermissive" \
    USER_WARNINGS='-Wno-strict-overflow'
