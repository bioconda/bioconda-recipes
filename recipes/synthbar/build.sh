#!/bin/bash

export CFLAGS="${CFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CC="${CC}"

export CPATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"

mkdir -p "${PREFIX}/bin"

make CC="${CC}" LDFLAGS="${LDFLAGS}" -j"${CPU_COUNT}"

install -v -m 0755 synthbar "${PREFIX}/bin"
