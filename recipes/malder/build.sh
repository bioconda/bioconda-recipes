#!/usr/bin/env bash

cd MALDER

make \
    CXX="${CXX}" \
    CXXFLAGS="${CXXFLAGS} -Wall -Wno-return-type -Wno-write-strings -Iadmixtools_src -Iadmixtools_src/nicksrc" \
    CFLAGS="${CFLAGS} -c -O2 -Wimplicit -Wno-return-type -Wno-write-strings -I. -I./nicksrc" \
    L="${LDFLAGS} -lfftw3 -llapack -lgsl -fopenmp"

mkdir -p "${PREFIX}/bin"
cp malder "${PREFIX}/bin/"
