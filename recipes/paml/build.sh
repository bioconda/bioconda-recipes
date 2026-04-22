#!/bin/bash
set -eu -o pipefail

mkdir -p "${PREFIX}/bin"

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3"

cd src

make CC="${CC}" CFLAGS="${CFLAGS}" -j"${CPU_COUNT}"

"${CC}" -o ds -O3 ds.c tools.c -lm

install -v -m 0755 baseml basemlg \
	chi2 codeml ds evolver infinitesites \
	mcmctree pamp yn00 \
	"${PREFIX}/bin"

cp -rf "${SRC_DIR}/dat" ${PREFIX}/
