#!/bin/bash
mkdir -p "${PREFIX}/bin"
export MACHTYPE=x86_64
export BINDIR=`pwd`/bin
export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="-L${PREFIX}/lib"
export CFLAGS="-I${PREFIX}/include ${LDFLAGS}"
export L="${LDFLAGS}"
mkdir -p ${BINDIR}
(cd kent/src/lib && make CC=${CC} CFLAGS="${CFLAGS}")
(cd kent/src/htslib && make CC=${CC} CFLAGS="${CFLAGS}")
(cd kent/src/jkOwnLib && make CC=${CC} CFLAGS="${CFLAGS}")
(cd kent/src/hg/lib && make CC=${CC} CFLAGS="${CFLAGS}")
# (cd kent/src/blat && make CC=${CC} CFLAGS="${CFLAGS}")
cp blat "${PREFIX}/bin"
chmod +rx "${PREFIX}/bin/blat"
