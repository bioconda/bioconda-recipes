#!/bin/bash
set -x -e

mkdir -p ${PREFIX}/bin
make CC="${CC}" CFLAGS="${CFLAGS} -O3 -L${PREFIX}/lib" -j"${CPU_COUNT}"

install -v -m 0755 nseg ${PREFIX}/bin
install -v -m 0755 nmerge ${PREFIX}/bin
