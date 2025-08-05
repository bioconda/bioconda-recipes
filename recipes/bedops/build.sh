#!/bin/bash
set -eu -o pipefail

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3"
export CXXFLAGS="${CXXFLAGS} -O3"

mkdir -p "${PREFIX}/bin"

rm -rf third-party

make BUILD_ARCH="$(uname -m)" \
	JPARALLEL="${CPU_COUNT}" \
	CC="${CC}" CXX="${CXX}" \
	LOCALBZIP2LIB="-lbz2" \
	LOCALJANSSONLIB="-ljansson" \
	LOCALZLIBLIB="-lz"
make install_all BINDIR="${PREFIX}/bin"

chmod 755 "${PREFIX}/bin/*"
