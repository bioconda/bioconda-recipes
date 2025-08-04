#!/bin/bash

install -d "${PREFIX}/bin"

make CC="${CC} ${CFLAGS} ${CPPFLAGS}" LL="${CC} ${LDFLAGS}" -j"${CPU_COUNT}"
install -v -m 0755 GotohScan "${PREFIX}/bin"
