#!/bin/bash

set -xe

export MACHTYPE=$(uname -m)
export BINDIR=$(pwd)/bin

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export L="${LDFLAGS}"
export CFLAGS="${CFLAGS} -O3 -I${PREFIX}/include"
export COPT="${COPT} ${CFLAGS}"
export CXXFLAGS="${CXXFLAGS} -O3 -I${PREFIX}/include"

mkdir -p "${PREFIX}/bin"
mkdir -p "${BINDIR}"

sed -i.bak -e 's|${LINKLIBS} ${L}|${LINKLIBS} ${L} -ldl -lm -lc -liconv|' kent/src/inc/userApp.mk
sed -i.bak -e 's|${CC} ${COPT}|${CC} ${LDFLAGS} $(CPPFLAGS) ${COPT}|' kent/src/inc/userApp.mk
sed -i.bak -e 's|-lpthread|-pthread|' kent/src/inc/common.mk

rm -rf kent/src/inc/*.bak

cd kent/src/htslib
autoreconf -if
./configure --prefix=`$(pwd)` \
  --enable-libcurl --enable-plugins --disable-option-checking \
  CC="${CC}" CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" \
  CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"

make clean
make -j"${CPU_COUNT}"
cd ../../../

(cd kent/src/lib && make CC="${CC}" CXX="${CXX}" CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" -j"${CPU_COUNT}")
(cd kent/src/htslib && make CC="${CC}" CXX="${CXX}" CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" -j"${CPU_COUNT}")
(cd kent/src/jkOwnLib && make CC="${CC}" CXX="${CXX}" CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" -j"${CPU_COUNT}")
(cd kent/src/hg/lib && make USE_HIC=0 CC="${CC}" CXX="${CXX}" CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" -j"${CPU_COUNT}")
(cd kent/src/hg/bedToGenePred && make CC="${CC}" CXX="${CXX}" CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" -j"${CPU_COUNT}")
install -v -m 0755 bin/bedToGenePred "${PREFIX}/bin"
