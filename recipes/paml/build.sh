#!/bin/bash
set -eu -o pipefail

mkdir -p "${PREFIX}/bin"

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"

if [[ "$(uname -s)" == "Darwin" ]]; then
	sed -i.bak 's|-O3|-O3 -std=gnu11 -fcommon -Wno-deprecated-declarations|' src/Makefile
	rm -rf src/*.bak
fi

sed -i.bak 's|CC = gcc|CC ?= $(CC)|' src/Makefile

cd src

make CC="${CC}"
"${CC}" -o ds -O3 ds.c tools.c -lm

install -v -m 0755 baseml basemlg \
	chi2 codeml ds evolver infinitesites \
	mcmctree pamp yn00 \
	"${PREFIX}/bin"

cd ..

cp -rf dat ${PREFIX}/
