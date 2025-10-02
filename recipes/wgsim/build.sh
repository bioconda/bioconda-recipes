#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3"

"${CC}" ${CFLAGS} ${CPPFLAGS} ${LDFLAGS} -o wgsim wgsim.c -lz -lm

mkdir -p "${PREFIX}/bin"

install -v -m 0755 wgsim wgsim_eval.pl "${PREFIX}/bin"
