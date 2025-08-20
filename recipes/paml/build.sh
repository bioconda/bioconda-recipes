#!/bin/bash
set -eu -o pipefail

mkdir -p "${PREFIX}/bin"

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3 -Wno-deprecated-declarations -Wno-implicit-function-declaration -Wno-unused-result"

sed -i.bak 's|CC = gcc|CC ?= $(CC)|' src/Makefile
rm -rf src/*.bak

cd src

if [[ "$(uname -s)" == "Darwin" ]]; then
	"${CC}" ${CPPFLAGS} ${CFLAGS} ${LDFLAGS} -o baseml baseml.c tools.c -lm
	"${CC}" ${CPPFLAGS} ${CFLAGS} ${LDFLAGS} -o basemlg basemlg.c tools.c -lm
	"${CC}" ${CPPFLAGS} ${CFLAGS} ${LDFLAGS} -o codeml codeml.c tools.c -lm
	"${CC}" ${CPPFLAGS} ${CFLAGS} ${LDFLAGS} -o pamp pamp.c tools.c -lm
	"${CC}" ${CPPFLAGS} ${CFLAGS} ${LDFLAGS} -o mcmctree mcmctree.c tools.c -lm
	"${CC}" ${CPPFLAGS} ${CFLAGS} ${LDFLAGS} -o infinitesites -D INFINITESITES mcmctree.c tools.c -lm
	"${CC}" ${CPPFLAGS} ${CFLAGS} ${LDFLAGS} -o evolver evolver.c tools.c -lm
	"${CC}" ${CPPFLAGS} ${CFLAGS} ${LDFLAGS} -o yn00 yn00.c tools.c -lm
	"${CC}" ${CPPFLAGS} ${CFLAGS} ${LDFLAGS} -o chi2 chi2.c -lm
	"${CC}" ${CPPFLAGS} ${CFLAGS} ${LDFLAGS} -o ds ds.c tools.c -lm
else
	make -j"${CPU_COUNT}"
	"${CC}" -O3 -o ds ds.c tools.c -lm
fi

install -v -m 0755 baseml basemlg \
	chi2 codeml ds evolver infinitesites \
	mcmctree pamp yn00 \
	"${PREFIX}/bin"

cd ..

cp -rf dat ${PREFIX}/
