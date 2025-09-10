#!/bin/bash
set -eu -o pipefail

mkdir -p "${PREFIX}/bin"

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3 -std=c11 -I${PREFIX}/include"

if [[ "$(uname -s)" == "Darwin" ]]; then
	sed -i.bak 's|-O3|-O3 -std=c11|' src/Makefile
	rm -rf src/*.bak
fi

cd src

make CC="${CC}" CFLAGS="${CFLAGS}" -j"${CPU_COUNT}"
"${CC}" -o ds -O3 ds.c tools.c -lm

install -v -m 0755 baseml basemlg \
	chi2 codeml ds evolver infinitesites \
	mcmctree pamp yn00 \
	"${PREFIX}/bin"

cd ..
cp -rf dat ${PREFIX}/
