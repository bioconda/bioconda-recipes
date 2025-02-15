#!/bin/bash
set -eu -o pipefail

# Build SvABA
cmake -DHTSLIB_DIR=${PREFIX}/htslib
make CC=${CC} CXX=${CXX} CFLAGS="-fcommon ${CFLAGS} -L${PREFIX}/lib" CXXFLAGS="-fcommon ${CXXFLAGS} -UNDEBUG -L${PREFIX}/lib" LDFLAGS="${LDFLAGS}"

mkdir -p ${PREFIX}/bin
cp svaba ${PREFIX}/bin/
