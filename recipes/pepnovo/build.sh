#!/bin/bash

cd src/

# Below we add -Wno-narrowing because of the compilation error:
#   CumulativeSeqProb.h:10:71: error: narrowing conversion of '999999999' from 'int' to 'float' inside { } [-Wnarrowing]
make CC="${CXX}" CFLAGS="${CXXFLAGS} -Wno-narrowing " LDFLAGS="${LDFLAGS}"

mkdir -p ${PREFIX}/bin
cp PepNovo_bin ${PREFIX}/bin/pepnovo
