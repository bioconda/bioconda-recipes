#!/bin/bash

set -xe

mkdir -p "${PREFIX}/bin"
export MACHTYPE=$(uname -m)
export BINDIR=$(pwd)/bin
export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3 ${LDFLAGS}"
export CXXFLAGS="${CXXFLAGS} -I${PREFIX}/include ${LDFLAGS}"
export L="${LDFLAGS}"
mkdir -p "${BINDIR}"
(cd kent/src/lib && make CC="${CC}" CXX="${CXX}" CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" -j "${CPU_COUNT}")
(cd kent/src/htslib && make CC="${CC}" CXX="${CXX}" CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" -j "${CPU_COUNT}")
(cd kent/src/jkOwnLib && make CC="${CC}" CXX="${CXX}" CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" -j "${CPU_COUNT}")
(cd kent/src/hg/lib && make USE_HIC=0 CC="${CC}" CXX="${CXX}" CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" -j "${CPU_COUNT}")
(cd kent/src/utils/splitFileByColumn && make CC="${CC}" CXX="${CXX}" CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" -j "${CPU_COUNT}")
cp bin/splitFileByColumn "${PREFIX}/bin"
chmod 0755 "${PREFIX}/bin/splitFileByColumn"
