#!/bin/bash
set -euo pipefail

mkdir -p "${PREFIX}/bin"

export INCLUDES="-I${PREFIX}/inc"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3"

make CC="${CC} -O3" CFLAGS="${CFLAGS}" CXX="${CXX}" LDFLAGS="${LDFLAGS}" \
	CXXFLAGS="${CXXFLAGS} -O3 -I${PREFIX}/inc" \
	CPP="${CXX}" CPPFLAGS="${CXXFLAGS} -O3 -I${PREFIX}/inc" \
	INCLUDES="${INCLUDES}" -j"${CPU_COUNT}"

chmod 0755 MuSE
cp -f MuSE "${PREFIX}/bin"
