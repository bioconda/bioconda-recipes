#!/bin/bash
set -xeu -o pipefail

mkdir build && cd build
cmake -DHTSLIB_DIR=${PREFIX}/htslib ..
make -j"${CPU_COUNT}" CC=${CC} CXX=${CXX} CFLAGS="-fcommon ${CFLAGS} -L${PREFIX}/lib" CXXFLAGS="-fcommon ${CXXFLAGS} -UNDEBUG -L${PREFIX}/lib" LDFLAGS="${LDFLAGS}"

mkdir -p ${PREFIX}/bin
install -v -m 0755 svaba ${PREFIX}/bin/
