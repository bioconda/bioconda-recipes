#!/bin/bash

export CFLAGS="-I${PREFIX}/include -Ihtslib/htslib"
export LDFLAGS="-L${PREFIX}/lib"

make CC="${CC}" CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}"

mkdir -p "${PREFIX}/bin"
cp yame "${PREFIX}/bin/"

