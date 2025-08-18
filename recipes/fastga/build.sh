#!/bin/bash

mkdir -p ${PREFIX}/bin

export CFLAGS="${CFLAGS} -O3 -I$PREFIX/include -L$PREFIX/lib"

make -j"${CPU_COUNT}" CC="${CC}" CFLAGS="${CFLAGS}"

install -v -m 0755 FastGA \
    FAtoGDB GIXmake ALNtoPAF ALNtoPSL \
    GDBshow GDBstat GIXshow ALNshow ALNplot \
    GDBtoFA GIXrm GIXcp GIXmv ALNchain ALNreset PAFtoALN PAFtoPSL \
    ONEview $PREFIX/bin
