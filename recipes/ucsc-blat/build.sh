#!/bin/bash
export USE_HIC=0
mkdir -p "${PREFIX}/bin"
export MACHTYPE=$(uname -m)
export BINDIR=`pwd`/bin
export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3 ${LDFLAGS}"
export CXXFLAGS="${CXXFLAGS} -I${PREFIX}/include ${LDFLAGS}"
export L="${LDFLAGS}"
mkdir -p ${BINDIR}
(cd ${SRC_DIR}/kent/src/lib && make CC="${CC}" CXX="${CXX}" CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" -j "${CPU_COUNT}")
(cd ${SRC_DIR}/kent/src/htslib && make CC="${CC}" CXX="${CXX}" CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" -j "${CPU_COUNT}")
(cd ${SRC_DIR}/kent/src/jkOwnLib && make CC="${CC}" CXX="${CXX}" CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" -j "${CPU_COUNT}")
(cd ${SRC_DIR}/kent/src/blat && make CC="${CC}" CXX="${CXX}" CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" -j "${CPU_COUNT}")
cp -f ${SRC_DIR}/bin/blat "${PREFIX}/bin"
chmod 0755 "${PREFIX}/bin/blat"
