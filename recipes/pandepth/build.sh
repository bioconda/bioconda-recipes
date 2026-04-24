#!/bin/bash
set -eu -o pipefail

sed -i 's/g++/${CXX}/g' Makefile

make CXX="${CXX}" \
     CXXFLAGS="${CXXFLAGS} -I${PREFIX}/include -O3" \
     LDFLAGS="${LDFLAGS} -L${PREFIX}/lib -lhts -lz"

mkdir -p ${PREFIX}/bin
cp bin/pandepth ${PREFIX}/bin/

chmod +x ${PREFIX}/bin/pandepth
