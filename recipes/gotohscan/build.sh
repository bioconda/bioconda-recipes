#!/bin/sh

make CC="${CC} ${CFLAGS} ${CPPFLAGS}" LL="${CC} ${LDFLAGS}"
install -d "${PREFIX}/bin"
install GotohScan "${PREFIX}/bin/"
