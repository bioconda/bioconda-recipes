#!/bin/bash
set -eu -o pipefail

make CXX="${CXX}" \
     CXXFLAGS="${CXXFLAGS} -I${PREFIX}/include -O3" \
     LDFLAGS="${LDFLAGS} -L${PREFIX}/lib -lhts -lz"

mkdir -p ${PREFIX}/bin
cp bin/pandepth ${PREFIX}/bin/

chmod +x ${PREFIX}/bin/pandepth
