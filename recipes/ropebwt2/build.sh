#!/bin/bash
set -xe

mkdir -p "${PREFIX}/bin"

make CC="${CC}" \
	CFLAGS="${CFLAGS} -fcommon -g -Wall -O3" \
	LIBS="${LDFLAGS} -L${PREFIX}/lib -lz -pthread" \
	-j"${CPU_COUNT}"

install -v -m 0755 ropebwt2 "${PREFIX}/bin"
