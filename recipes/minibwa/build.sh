#!/bin/bash

set -xe

mkdir -p "${PREFIX}/bin" "${PREFIX}/lib" "${PREFIX}/include" "${PREFIX}/man/man1"

make \
    CC="${CC}" \
    CFLAGS="${CFLAGS}" \
    CPPFLAGS="${CPPFLAGS}" \
    LDFLAGS="${LDFLAGS}" \
    -j"${CPU_COUNT}" \
    minibwa

install -m 0755 minibwa "${PREFIX}/bin"
install -m 0644 libminibwa.a "${PREFIX}/lib"
install -m 0644 minibwa.h "${PREFIX}/include"
install -m 0644 minibwa.1 "${PREFIX}/man/man1"
