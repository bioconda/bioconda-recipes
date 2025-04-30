#!/bin/bash

set -xe

export MACHTYPE=$(uname -m)
export BINDIR=$(pwd)/bin

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export L="${LDFLAGS}"
export CFLAGS="${CFLAGS} -O3 -I${PREFIX}/include -L${PREFIX}/lib"
export COPT="${COPT} ${CFLAGS}"
export CXXFLAGS="${CXXFLAGS} -O3 -I${PREFIX}/include"
export USE_HIC=0

mkdir -p "${PREFIX}/bin"
mkdir -p "${BINDIR}"

#sed -i.bak -e 's|-ldl -lm -lc|-ldl -lm -lc -lhts -lcurl|' kent/src/inc/common.mk
sed -i.bak -e 's|-lstdc++ -lrt|-lstdc++ -lrt -lhts|' kent/src/inc/common.mk

rm -rf kent/src/inc/*.bak

(cd kent/src/lib && make CC="${CC}" COPT="${COPT}" CXX="${CXX}" CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" L="${L}" -j"${CPU_COUNT}")
(cd kent/src/htslib && make CC="${CC}" COPT="${COPT}" CXX="${CXX}" CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" L="${L}" -j"${CPU_COUNT}")
(cd kent/src/jkOwnLib && make CC="${CC}" COPT="${COPT}" CXX="${CXX}" CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" L="${L}" -j"${CPU_COUNT}")
(cd kent/src/hg/lib && make CC="${CC}" COPT="${COPT}" CXX="${CXX}" CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" L="${L}" -j"${CPU_COUNT}")
(cd kent/src/hg/bedToGenePred && make CC="${CC}" COPT="${COPT}" CXX="${CXX}" CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" L="${L}" -j"${CPU_COUNT}")
install -v -m 0755 bin/bedToGenePred "${PREFIX}/bin"
