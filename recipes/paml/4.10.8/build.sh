#!/bin/bash
set -eu -o pipefail

mkdir -p "${PREFIX}/bin"

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3 -Wno-deprecated-declarations -Wno-implicit-function-declaration"

if [[ "$(uname -s)" == "Darwin" ]]; then
	sed -i.bak 's|-O3|-O3 -fcommon|' src/Makefile
	rm -rf src/*.bak
fi

cd src

make CC="${CC}" CFLAGS="${CFLAGS} -fcommon" -j"${CPU_COUNT}"

install -v -m 0755 baseml basemlg \
	chi2 codeml evolver infinitesites \
	mcmctree pamp yn00 \
	"${PREFIX}/bin"

cd ..

cp -rf dat ${PREFIX}/
