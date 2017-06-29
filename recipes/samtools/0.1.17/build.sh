#!/bin/bash

CFLAGS="-fPIC ${CFLAGS}"

env CFLAGS="${CFLAGS} $(pkg-config --cflags zlib)" \
    LDFLAGS="${LDFLAGS} $(pkg-config --libs zlib)" \
    make

install -d "${PREFIX}/include/${PKG_NAME}"
install -d "${PREFIX}/lib"
install bam.h sam.h bgzf.h khash.h faidx.h \
    "${PREFIX}/include/${PKG_NAME}"
install libbam.a "${PREFIX}/lib"
