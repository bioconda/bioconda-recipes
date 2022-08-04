#!/bin/bash

make CC="${CC}" CFLAGS="${CFLAGS} ${CPPFLAGS} ${LDFLAGS}"

mkdir -p "${PREFIX}/bin"
make install INSTALLDIR="${PREFIX}/bin/"
install smartdenovo.pl "${PREFIX}/bin/"
