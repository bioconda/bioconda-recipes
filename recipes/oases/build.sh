#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3"

mkdir -p "$PREFIX/bin"

make 'CATEGORIES=4' 'MAXKMERLENGTH=192' 'OPENMP=1' 'LONGSEQUENCES=1' 'BUNDLEDZLIB=1' \
	CC="${CC}" \
	CFLAGS="${CFLAGS}" \
	LDFLAGS="${LDFLAGS}"

install -v -m 0755 oases scripts/oases_pipeline.py "$PREFIX/bin"
