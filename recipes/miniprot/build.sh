#!/bin/bash
set -xe

if [[ ! -d ${PREFIX}/bin ]]; then
	mkdir -p ${PREFIX}/bin
fi

if [[ ! -d ${PREFIX}/share/man/man1 ]]; then
	mkdir -p ${PREFIX}/share/man/man1
fi

make CC="${CC}" CFLAGS="${CFLAGS} -O3 -I${PREFIX}/include" LIBS="${LDFLAGS} -L${PREFIX}/lib -pthread -lz -lm" -j"${CPU_COUNT}"

cp -f miniprot.1 ${PREFIX}/share/man/man1
install -v -m 0755 miniprot "${PREFIX}/bin"
