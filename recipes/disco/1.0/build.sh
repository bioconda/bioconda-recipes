#!/bin/bash

make clean
make all \
    CC="mpic++ ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS}" \
    CXX="${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS}"

mkdir -p "${PREFIX}/bin"
cp \
    buildG* \
    fullsimplify \
    parsimplify \
    disco* \
    run* \
    "${PREFIX}/bin/"
