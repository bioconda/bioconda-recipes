#!/bin/bash
set -eu -o pipefail

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3"
export CXXFLAGS="${CXXFLAGS} -O3"

mkdir -p "${PREFIX}/bin"

sed -i.bak 's|${LOCALJANSSONLIB} ${LOCALBZIP2LIB} ${LOCALZLIBLIB}|-L$(PREFIX)/lib -ljansson -lz -lbz2|' applications/bed/*/src/Makefile.darwin
rm -rf third-party

make BUILD_ARCH="$(uname -m)" \
	JPARALLEL="${CPU_COUNT}" \
	CC="${CC}" CXX="${CXX}" \
	LOCALBZIP2LIB="-lbz2" \
	LOCALJANSSONLIB="-ljansson" \
	LOCALZLIBLIB="-lz"

make install BINDIR="${PREFIX}/bin"
