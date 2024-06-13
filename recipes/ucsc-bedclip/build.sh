#!/bin/bash

if [ $(arch) = "aarch64" ]
then
    export CFLAGS+=" -O3 "
    export CPPFLAGS+=" -O3 "
else
    export MACHTYPE=x86_64
fi

export BINDIR=$(pwd)/bin
export L="${LDFLAGS}"
export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3 ${LDFLAGS}"
export CXXFLAGS="${CXXFLAGS} -I${PREFIX}/include ${LDFLAGS}"
mkdir -p "$PREFIX/bin"
mkdir -p "$BINDIR"
(cd kent/src/lib && make CC="${CC}" CXX="${CXX}" CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" -j "${CPU_COUNT}")
(cd kent/src/htslib && make CC="${CC}" CXX="${CXX}" CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" -j "${CPU_COUNT}")
(cd kent/src/jkOwnLib && make CC="${CC}" CXX="${CXX}" CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" -j "${CPU_COUNT}")
(cd kent/src/hg/lib && USE_HIC=0 make CC="${CC}" CXX="${CXX}" CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" -j "${CPU_COUNT}")
(cd kent/src/utils/bedClip && make CC="${CC}" CXX="${CXX}" CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" -j "${CPU_COUNT}")
cp -f bin/bedClip "$PREFIX/bin"
chmod 0755 "$PREFIX/bin/bedClip"
