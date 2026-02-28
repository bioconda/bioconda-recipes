#!/bin/bash

mkdir -p "${PREFIX}/bin"

make clean
make CFLAGS="${CFLAGS} -O3" CPPFLAGS="${CPPFLAGS}" prefix="${PREFIX}" CC="${CC}" CXX="${CXX} -L${PREFIX}/lib" LDFLAGS+="-lz -pthread ${LDFLAGS} -L${PREFIX}/lib" -j"${CPU_COUNT}"

install -v -m 755 ./refFinder "${PREFIX}/bin"
