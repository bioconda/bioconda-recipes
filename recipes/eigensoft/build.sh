#!/usr/bin/env bash
set -xeuo pipefail

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export INCLUDE_PATH="${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3"

mkdir -p "$PREFIX/bin"

cd src

make CC="${CC}" -j"${CPU_COUNT}" all

install -v -m 0755 baseprog convertf mergeit pca \
	eigensrc/pcatoy eigensrc/smartrel eigensrc/smarteigenstrat eigensrc/twstats \
	eigensrc/eigenstrat eigensrc/eigenstratQTL eigensrc/smartpca "${PREFIX}/bin"
