#!/bin/bash
set -eu -o pipefail
make CC=${CC} CXX=${CXX} CFLAGS="${CFLAGS} -L${PREFIX}/lib"  CXXFLAGS="${CXXFLAGS} -L${PREFIX}/lib" LDFLAGS="${LDFLAGS}"
make

mkdir -p ${PREFIX}/bin
cp ./divvier ${PREFIX}/bin/
