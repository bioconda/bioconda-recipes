#!/bin/bash

mkdir -p "${PREFIX}/bin"
make \
    VERBOSE=1 \
    CXX="${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS}" \
    PREFIX="${PREFIX}" \
    install
