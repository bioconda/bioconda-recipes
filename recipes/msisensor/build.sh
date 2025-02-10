#!/bin/bash

set -xe

CFLAGS="${CFLAGS} ${LDFLAGS}" \
    make -j"${CPU_COUNT}" \
    CXX="${CXX}" CC="${CC}"
install -d "${PREFIX}/bin"
install -m 755 msisensor "${PREFIX}/bin/"
