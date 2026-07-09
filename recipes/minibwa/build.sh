#!/bin/bash

set -xe

mkdir -p "${PREFIX}/bin" "${PREFIX}/lib" "${PREFIX}/include"

# CC drives the Makefile's OpenMP auto-detection. The override-makefile.patch
# lets the Makefile append its OpenMP/GPL/SSE4.2 flags on top of conda's
# CFLAGS/CPPFLAGS rather than having them clobbered by the command line.
# LIBS is left untouched so the Makefile keeps -lpthread -lz -lm.
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
