#!/bin/bash
set -xe

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"

mkdir -p ${PREFIX}/bin

make miniprot_boundary_scorer CC="${CXX}" CFLAGS="${CFLAGS} -O3 -c -Wall -std=c++14" LDFLAGS="${LDFLAGS} -L${PREFIX}/lib" -j"${CPU_COUNT}"

install -v -m 0755 miniprot_boundary_scorer "${PREFIX}/bin"
