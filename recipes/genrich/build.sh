#!/bin/bash

export CFLAGS="${CFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

make CC="${CC}" CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}"
mkdir -p "${PREFIX}/bin"
install -v -m 0755 Genrich "${PREFIX}/bin"
