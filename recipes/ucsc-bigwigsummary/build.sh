#!/bin/bash

mkdir -p "$PREFIX/bin"

export MACHTYPE=$(uname -m)
export BINDIR=$(pwd)/bin
export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3 ${LDFLAGS}"
export L="${LDFLAGS}"

mkdir -p "$BINDIR"

if [[ "$(uname)" == Darwin ]]; then
	export LDFLAGS="${LDFLAGS} -Wl,-rpath,${PREFIX}/lib"
	export CFLAGS="${CFLAGS} -Wno-unused-command-line-argument"
fi

(cd kent/src/lib && make CC="${CC}" CFLAGS="${CFLAGS}" -j ${CPU_COUNT})
(cd kent/src/htslib && make CC="${CC}" CFLAGS="${CFLAGS}" -j ${CPU_COUNT})
(cd kent/src/jkOwnLib && make CC="${CC}" CFLAGS="${CFLAGS}" -j ${CPU_COUNT})
(cd kent/src/hg/lib && make CC="${CC}" CFLAGS="${CFLAGS}" -j ${CPU_COUNT})
(cd kent/src/utils/bigWigSummary && make CC="${CC}" CFLAGS="${CFLAGS}" -j ${CPU_COUNT})
cp bin/bigWigSummary "$PREFIX/bin"
chmod 0755 "$PREFIX/bin/bigWigSummary"
