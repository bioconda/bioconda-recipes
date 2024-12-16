#!/bin/bash

set -xe

cd src/

# Below we add -Wno-narrowing because of the compilation error:
#   CumulativeSeqProb.h:10:71: error: narrowing conversion of '999999999' from 'int' to 'float' inside { } [-Wnarrowing]
make -j ${CPU_COUNT} CC="${CXX}" CFLAGS="${CXXFLAGS} -Wno-narrowing -Wno-register " LDFLAGS="${LDFLAGS}"

mkdir -p ${PREFIX}/bin
cp PepNovo_bin ${PREFIX}/bin/pepnovo
