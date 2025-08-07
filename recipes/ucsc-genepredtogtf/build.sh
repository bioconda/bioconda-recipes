#!/bin/bash
set -xe

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

if [[ "$(uname -m)" == "arm64" ]]; then
	rsync -aP rsync://hgdownload.cse.ucsc.edu/genome/admin/exe/macOSX.arm64/genePredToGtf .
	install -v -m 755 genePredToGtf "${PREFIX}/bin"
else
	(cd kent/src && make libs USE_HIC=0 PTHREADLIB=1 CC="${CC}" CXX="${CXX}" -j"${CPU_COUNT}")
	(cd kent/src/hg/genePredToGtf && make CC="${CC}" -j"${CPU_COUNT}")
	install -v -m 755 bin/genePredToGtf "${PREFIX}/bin"
fi
