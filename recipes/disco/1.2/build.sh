#!/bin/bash

set -eo pipefail

make clean
make all \
    CC="mpic++ ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS}" \
    CXX="${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS}" \
    READGZ=1

mkdir -p "${PREFIX}/bin"
cp \
    buildG* \
    fullsimplify \
    parsimplify \
    disco* \
    run* \
    "${PREFIX}/bin/"
