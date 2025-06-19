#!/bin/bash

mkdir -p "${PREFIX}/bin"
export MACHTYPE="$(uname -m)"
export BINDIR="$(pwd)/bin"
mkdir -p "$(pwd)/bin"
export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3"
export COPT="${COPT} ${CFLAGS}"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"
export L="${LDFLAGS}"

if [[ "$(uname -s)" == "Darwin" ]]; then
        export LDFLAGS="${LDFLAGS} -Wl,-rpath,${PREFIX}/lib"
        export CFLAGS="${CFLAGS} -Wno-unused-command-line-argument"
fi

(cd kent/src/lib && make CC="${CC}" CXX="${CXX}" CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" -j"${CPU_COUNT}")
(cd kent/src/htslib && make CC="${CC}" CXX="${CXX}" CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" -j"${CPU_COUNT}")
(cd kent/src/jkOwnLib && make CC="${CC}" CXX="${CXX}" CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" -j"${CPU_COUNT}")
(cd kent/src/hg/lib && make USE_HIC=0 CC="${CC}" CXX="${CXX}" CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" -j"${CPU_COUNT}")
(cd kent/src/hg/utils/faToVcf && make CC="${CC}" CXX="${CXX}" CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" -j"${CPU_COUNT}")
install -v -m 755 bin/faToVcf "${PREFIX}/bin"
