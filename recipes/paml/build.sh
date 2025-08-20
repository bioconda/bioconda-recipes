#!/bin/bash
set -eu -o pipefail

mkdir -p "${PREFIX}/bin"

export C_INCLUDE_PATH="${PREFIX}/include"
export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"

sed -i.bak 's|CC = gcc|CC ?= $(CC)|' src/Makefile
rm -rf src/*.bak

cd src

if [[ "$(uname -s)" == "Darwin" ]]; then
	"${CC}" -I${PREFIX}/include -O3 -Wno-unused-result -nostdinc -o baseml baseml.c tools.c -lm
	"${CC}" -I${PREFIX}/include -O3 -Wno-unused-result -nostdinc -o basemlg basemlg.c tools.c -lm
	"${CC}" -I${PREFIX}/include -O3 -Wno-unused-result -nostdinc -o codeml codeml.c tools.c -lm
	"${CC}" -I${PREFIX}/include -O3 -Wno-unused-result -nostdinc -o pamp pamp.c tools.c -lm
	"${CC}" -I${PREFIX}/include -O3 -Wno-unused-result -nostdinc -o mcmctree mcmctree.c tools.c -lm
	"${CC}" -I${PREFIX}/include -O3 -Wno-unused-result -nostdinc -o infinitesites -D INFINITESITES mcmctree.c tools.c -lm
	"${CC}" -I${PREFIX}/include -O3 -Wno-unused-result -nostdinc -o evolver evolver.c tools.c -lm
	"${CC}" -I${PREFIX}/include -O3 -Wno-unused-result -nostdinc -o yn00 yn00.c tools.c -lm
	"${CC}" -I${PREFIX}/include -O3 -Wno-unused-result -nostdinc -o chi2 chi2.c -lm
	"${CC}" -I${PREFIX}/include -O3 -Wno-unused-result -nostdinc -o ds ds.c tools.c -lm
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
