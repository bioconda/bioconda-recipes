#!/bin/bash
set -euxo pipefail

make -j"${CPU_COUNT:-1}" \
    CC="${CXX}" \
    CXX="${CXX}" \
    CFLAGS="${CXXFLAGS}" \
    CXXFLAGS="${CXXFLAGS}" \
    LDFLAGS="${LDFLAGS} -lz -lm"

install -d "${PREFIX}/bin"
install -m 755 restrander "${PREFIX}/bin/restrander"

install -d "${PREFIX}/share/restrander/config"
cp config/*.json "${PREFIX}/share/restrander/config/"
