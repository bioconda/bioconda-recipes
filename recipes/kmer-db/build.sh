#!/bin/bash -euo

export CFLAGS="$CFLAGS -O3 -I${PREFIX}/include"
export LDFLAGS="$LDFLAGS -L${PREFIX}/lib"

make CC="${CXX}" -j "${CPU_COUNT}"
install -d "${PREFIX}/bin"
install kmer-db "${PREFIX}/bin"
